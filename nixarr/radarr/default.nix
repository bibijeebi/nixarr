{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.nixarr.radarr;
  nixarr = config.nixarr;
in {

  options.nixarr.radarr = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "Whether or not to enable the Radarr service.";
    };

    package = mkPackageOption pkgs "radarr" { };

    stateDir = mkOption {
      type = types.path;
      default = "${nixarr.stateDir}/radarr";
      defaultText = literalExpression ''"''${nixarr.stateDir}/radarr"'';
      description = mdDoc ''
        The location of the state directory for the Radarr service.

        > **Warning:** Setting this to any path, where the subpath is not
        > owned by root, will fail!
      '';
    };

    port = mkOption {
      type = types.port; # Changed to port type for better validation
      default = 7878;
      description = mdDoc "Port for the Radarr web interface";
    };

    openFirewall = mkOption {
      type = types.bool;
      defaultText = literalExpression "!nixarr.radarr.vpn.enable";
      default = !cfg.vpn.enable;
      description = mdDoc "Open firewall for Radarr";
    };

    vpn.enable = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "Route Radarr traffic through the VPN";
    };

    urlBase = mkOption {
      type = types.str;
      default = "";
      example = "/radarr";
      description = mdDoc "URL base for reverse proxy support";
    };

    authentication = {
      useFormLogin = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc "Use form-based login page instead of basic auth";
      };

      disabledForLocalAddresses = mkOption {
        type = types.bool;
        default = false;
        description =
          mdDoc "Disable authentication for local network addresses";
      };

      username = mkOption {
        type = types.str;
        default = "admin";
        description = mdDoc "Username for web interface access";
      };

      password = mkOption {
        type = types.str;
        default = "changeme";
        description = mdDoc "Password for web interface access";
      };
    };

    logLevel = mkOption {
      type = types.enum [ "Trace" "Debug" "Info" "Warn" "Error" ];
      default = "Info";
      description = mdDoc "Logging verbosity level";
    };
  };

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

    # Add systemd service hardening
    systemd.services.radarr = {
      serviceConfig = {
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadWritePaths = [ cfg.stateDir ];
        RestrictSUIDSGID = true;
      };
    };

    # Write the config.xml file
    system.activationScripts.configure-radarr = {
      text = ''
        # Create the state directory if it doesn't exist
        if [ ! -d "${cfg.stateDir}" ]; then
          mkdir -p "${cfg.stateDir}"
        fi

        # Write the config file if it doesn't exists
        if [ ! -f "${cfg.stateDir}/config.xml" ]; then
          cat <<'EOF' > "${cfg.stateDir}/config.xml"
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
          EOF
          chown radarr:media "${cfg.stateDir}/config.xml"
          chmod 600 "${cfg.stateDir}/config.xml"
        fi

        # Create the database file if it doesn't exist
        if [ ! -f "${cfg.stateDir}/radarr.db" ]; then
          ${pkgs.sqlite}/bin/sqlite3 "${cfg.stateDir}/radarr.db" <<'EOF'
            ${builtins.readFile ./radarr-db.sql}
        EOF
          chown radarr:media "${cfg.stateDir}/radarr.db"
          chmod 600 "${cfg.stateDir}/radarr.db"
        fi

        # Generate a new salt and hash the password using Python's cryptography
        HASH_RESULT=$(${pkgs.python3}/bin/python3 -c '
          import base64
          import hashlib
          import sys
          import os
          password = "${cfg.authentication.password}".encode('utf-8')
          salt = base64.b64encode(os.urandom(16)).decode('utf-8')
          iterations = 10000
          dk = hashlib.pbkdf2_hmac('sha256', password, salt, iterations, 32)
          print(f"{base64.b64encode(dk).decode('utf-8')}:{salt}")
        ')

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
            '$(uuidgen)',
            '${cfg.authentication.username}',
            '$(echo "$HASH_RESULT" | cut -d':' -f1)',
            '$(echo "$HASH_RESULT" | cut -d':' -f2)',
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
