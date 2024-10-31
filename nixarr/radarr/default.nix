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
    system.activationScripts.configure-radarr = {
      text = ''
        # Create the state directory if it doesn't exist
        if [ ! -d "${cfg.stateDir}" ]; then
          mkdir -p "${cfg.stateDir}"
        fi

        # Write the config file if it doesn't exists
        if [ ! -f "${configXmlPath}" ]; then
          echo "${configXmlText}" > "${configXmlPath}"
          chown radarr:media "${configXmlPath}"
          chmod 600 "${configXmlPath}"
        fi

        # Create the database file if it doesn't exist
        if [ ! -f "${cfg.stateDir}/radarr.db" ]; then
          ${pkgs.sqlite}/bin/sqlite3 "${cfg.stateDir}/radarr.db" <<EOF
            ${userSetupSQL}
          EOF
          chown radarr:media "${cfg.stateDir}/radarr.db"
          chmod 600 "${cfg.stateDir}/radarr.db"
        fi

        # Generate a new salt and hash the password using Python's cryptography
        HASH_RESULT=$(${ pkgs.python3.withPackages (ps: [ ps.cryptography ]) }/bin/python3 -c <<'EOF'
          import base64
          import os
          import sys
          import uuid
          from cryptography.hazmat.primitives import hashes
          from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC

          salt = os.urandom(16)
          salt_b64 = base64.b64encode(salt).decode('utf-8')

          kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=10000,
          )

          password = "${cfg.authentication.password}".encode('utf-8')

          key = kdf.derive(password)
          password_b64 = base64.b64encode(key).decode('utf-8')

          identifier = str(uuid.uuid4())

          print(f"{password_b64}:{salt_b64}:{identifier}")
        EOF
        )

        # Split the result into its components
        PASSWORD_HASH=$(echo "$HASH_RESULT" | cut -d':' -f1)
        SALT=$(echo "$HASH_RESULT" | cut -d':' -f2)
        IDENTIFIER=$(echo "$HASH_RESULT" | cut -d':' -f3)

        # Use SQLite to modify the database
        ${pkgs.sqlite}/bin/sqlite3 "${cfg.stateDir}/radarr.db" <<EOF
          BEGIN TRANSACTION;
          DELETE FROM Users;
          INSERT INTO Users (
            Identifier,
            Username,
            Password,
            Salt,
            Iterations
          ) VALUES (
            '$IDENTIFIER',
            '${cfg.authentication.username}',
            '$PASSWORD_HASH',
            '$SALT',
            10000
          );
          COMMIT;
        EOF

        # Ensure proper permissions
        chown radarr:media "${cfg.stateDir}/radarr.db"
        chmod 600 "${cfg.stateDir}/radarr.db"
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
