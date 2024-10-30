{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.nixarr.radarr;
  nixarr = config.nixarr;

  configXmlPath = "${cfg.stateDir}/config.xml";
  configXmlText = ''
    <?xml version="1.0" encoding="utf-8"?>
    <Config>
      <BindAddress>*</BindAddress>
      <Port>${builtins.toString cfg.port}</Port>
      <SslPort>9898</SslPort>
      <EnableSsl>false</EnableSsl>
      <LaunchBrowser>true</LaunchBrowser>
      <ApiKey>${
        builtins.substring 0 32
        (builtins.hashString "sha256" config.networking.hostName)
      }</ApiKey>
      <AuthenticationMethod>${
        if cfg.authentication.useFormLogin then "Forms" else "Basic"
      }</AuthenticationMethod>
      <AuthenticationRequired>${
        if cfg.authentication.disabledForLocalAddresses then
          "DisabledForLocalAddresses"
        else
          "Enabled"
      }</AuthenticationRequired>
      <Branch>master</Branch>
      <LogLevel>${cfg.logLevel}</LogLevel>
      <UrlBase>${cfg.urlBase}</UrlBase>
      <InstanceName>Radarr</InstanceName>
    </Config>
  '';


  # Function to generate SQL for user setup
  # We're using the exact format from Radarr's database
  generateUserSetupSQL = { password, salt, identifier }: ''
    BEGIN TRANSACTION;
    -- Delete existing users first to ensure clean state
    DELETE FROM Users;
    
    -- Insert the main admin user
    INSERT INTO Users (
      Identifier,
      Username,
      Password,
      Salt,
      Iterations
    ) VALUES (
      '${identifier}',
      '${cfg.authentication.username}',
      '${password}',
      '${salt}',
      10000
    );
    COMMIT;
  '';
  
in {

  imports = [ ./options.nix ];

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enable -> nixarr.enable;
        message = "nixarr.radarr.enable requires nixarr.enable to be true";
      }
      {
        assertion = cfg.vpn.enable -> nixarr.vpn.enable;
        message =
          "nixarr.radarr.vpn.enable requires nixarr.vpn.enable to be true";
      }
      {
        assertion = cfg.authentication.password != "";
        message = "Password must not be empty for Radarr authentication";
      }
    ];

    services.radarr = {
      enable = cfg.enable;
      package = cfg.package;
      user = "radarr";
      group = "media";
      openFirewall = cfg.openFirewall;
      dataDir = cfg.stateDir;
    };

    # Write the config.xml file
    system.activationScripts.radarr-config = {
      text = ''
        # Ensure the state directory exists
        mkdir -p "${cfg.stateDir}"

        # Write the config file if it doesn't exist or if we're forcing an update
        if [ ! -f "${configXmlPath}" ] || [ "$1" = "force" ]; then
          echo "${configXmlText}" > "${configXmlPath}"
          chown radarr:media "${configXmlPath}"
          chmod 600 "${configXmlPath}"
        fi

        # {
        #     "Id": 1,
        #     "Identifier": "5fe21d5d-48c1-460d-ba25-536bb3fe2657",
        #     "Username": "admin",
        #     "Password": "fmWOYFdp+k74XahsSAwRSQ3bzZWVL0nHhZTvOx9iUP4=",
        #     "Salt": "tTalJbk9HmfnG5ZN1CDnZw==",
        #     "Iterations": 10000
        # }
      '';
      deps = [ ];
    };

    # Setup the database with the correct user
    systemd.services.radarr = {
      postStart = ''
        DB_PATH="${cfg.stateDir}/radarr.db"
        SCHEMA_PATH="${cfg.stateDir}/radarr.db-shm"
        
        # Wait for the database file to exist (max 30 seconds)
        for i in {1..30}; do
          if [ -f "$DB_PATH" ]; then
            break
          fi
          echo "Waiting for database file to be created... ($i/30)"
          sleep 1
        done
        
        if [ ! -f "$DB_PATH" ]; then
          echo "Database file was not created in time"
          exit 1
        fi
        
        # Wait for the database to be ready (checking for schema file)
        for i in {1..30}; do
          if [ -f "$SCHEMA_PATH" ]; then
            break
          fi
          echo "Waiting for database schema to be ready... ($i/30)"
          sleep 1
        done

        # Generate a new salt and hash the password using Python's cryptography
        HASH_RESULT=$(${pkgs.python3}/bin/python3 ${pkgs.writeText "hash-password.py" ''
          import base64
          import os
          import sys
          from cryptography.hazmat.primitives import hashes
          from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
          
          # Generate a random salt
          salt = os.urandom(16)
          salt_b64 = base64.b64encode(salt).decode('utf-8')
          
          # Create PBKDF2 instance
          kdf = PBKDF2HMAC(
              algorithm=hashes.SHA256(),
              length=32,
              salt=salt,
              iterations=10000,
          )
          
          # Get password from environment
          password = os.environ['RADARR_PASSWORD'].encode('utf-8')
          
          # Generate the key
          key = kdf.derive(password)
          password_b64 = base64.b64encode(key).decode('utf-8')
          
          # Generate a new UUID for the identifier
          import uuid
          identifier = str(uuid.uuid4())
          
          # Print results in a format we can parse in the shell
          print(f"{password_b64}:{salt_b64}:{identifier}")
        ''} | RADARR_PASSWORD="${cfg.authentication.password}" PYTHONPATH="${pkgs.python3.pkgs.cryptography}/lib/python3.*/site-packages" -)
        
        # Split the result into its components
        PASSWORD_HASH=$(echo "$HASH_RESULT" | cut -d':' -f1)
        SALT=$(echo "$HASH_RESULT" | cut -d':' -f2)
        IDENTIFIER=$(echo "$HASH_RESULT" | cut -d':' -f3)
        
        # Use SQLite to modify the database
        ${pkgs.sqlite}/bin/sqlite3 "$DB_PATH" "$(generateUserSetupSQL {
          password = "$PASSWORD_HASH";
          salt = "$SALT";
          identifier = "$IDENTIFIER";
        })"
        
        # Ensure proper permissions
        chown radarr:media "$DB_PATH"
        chmod 600 "$DB_PATH"
      '';
    };

    # Enable and specify VPN namespace to confine service in.
    systemd.services.radarr.vpnConfinement = mkIf cfg.vpn.enable {
      enable = true;
      vpnNamespace = "wg";
    };

    # Keep your existing VPN namespace configuration
    vpnNamespaces.wg = mkIf cfg.vpn.enable {
      portMappings = [{
        from = cfg.port;
        to = cfg.port;
      }];
    };

    # Keep your existing Nginx configuration
    services.nginx = mkIf cfg.vpn.enable {
      enable = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;

      virtualHosts."127.0.0.1:${toString cfg.port}" = {
        listen = [{
          addr = "0.0.0.0";
          port = cfg.port;
        }];
        locations."/" = {
          recommendedProxySettings = true;
          proxyWebsockets = true;
          proxyPass = "http://192.168.15.1:${toString cfg.port}";
        };
      };
    };
  };
}
