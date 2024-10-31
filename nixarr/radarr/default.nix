{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.nixarr.radarr;
  nixarr = config.nixarr;

  generateApiKey = string:
    builtins.substring 0 32 (builtins.hashString "sha256" string);

  configXml = let
    bindAddress = "*";
    port = builtins.toString cfg.port;
    sslPort = "9898";
    enableSsl = "False";
    launchBrowser = "False";
    apiKey = generateApiKey "radarr@${config.networking.hostName}";
    authenticationMethod =
      if cfg.authentication.useFormLogin then "Forms" else "Basic";
    authenticationRequired =
      if cfg.authentication.disabledForLocalAddresses then
        "DisabledForLocalAddresses"
      else
        "Enabled";
    branch = "master";
    logLevel = cfg.logLevel;
    urlBase = cfg.urlBase;
    instanceName = "Radarr";
    theme = "dark";
  in ''
    <Config>
      <BindAddress>${bindAddress}</BindAddress>
      <Port>${port}</Port>
      <SslPort>${sslPort}</SslPort>
      <EnableSsl>${enableSsl}</EnableSsl>
      <LaunchBrowser>${launchBrowser}</LaunchBrowser>
      <ApiKey>${apiKey}</ApiKey>
      <AuthenticationMethod>${authenticationMethod}</AuthenticationMethod>
      <AuthenticationRequired>${authenticationRequired}</AuthenticationRequired>
      <Branch>${branch}</Branch>
      <LogLevel>${logLevel}</LogLevel>
      <UrlBase>${urlBase}</UrlBase>
      <InstanceName>${instanceName}</InstanceName>
      <Theme>${theme}</Theme>
    </Config>
  '';

  preStartScript = pkgs.writeShellApplication {
    name = "configure-radarr";
    runtimeInputs = with pkgs; [ sqlite jq openssl nodejs libuuid ];
    text = ''
      function log() {
        echo "[Radarr Setup] $1" >&2
      }

      function fail() {
        log "ERROR: $1"
        exit 1
      }

      # Verify state directory permissions
      if [ ! -w "${cfg.stateDir}" ]; then
        fail "State directory not writable: ${cfg.stateDir}"
      fi

      # Database verification
      if [ -f "${cfg.stateDir}/radarr.db" ]; then
        if ! sqlite3 "${cfg.stateDir}/radarr.db" "PRAGMA integrity_check;" | grep -q "ok"; then
          fail "Database corruption detected"
        fi
      fi

      # Create the state directory if it doesn't exist
      if [ ! -d "${cfg.stateDir}" ]; then
        mkdir -p "${cfg.stateDir}"
      fi

      # Write the config file if it doesn't exists
      if [ ! -f "${cfg.stateDir}/config.xml" ]; then
        cat <<'EOF' > "${cfg.stateDir}/config.xml"
        ${configXml}
        EOF
        chown radarr:media "${cfg.stateDir}/config.xml"
        chmod 600 "${cfg.stateDir}/config.xml"
      fi

      # Create the database file if it doesn't exist
      if [ ! -f "${cfg.stateDir}/radarr.db" ]; then
        sqlite3 "${cfg.stateDir}/radarr.db" <<'EOF'
        ${builtins.readFile ./init.sql}
        EOF
        chown radarr:media "${cfg.stateDir}/radarr.db"
        chmod 600 "${cfg.stateDir}/radarr.db"
      fi

      SALT=$(openssl rand 16 | base64)
      HASH=$(node -e "
        const crypto = require('crypto');
        const hash = crypto.pbkdf2Sync(process.argv[1], Buffer.from(process.argv[2], 'base64'), 10000, 32, 'sha512');
        console.log(hash.toString('base64'));
      " "${cfg.authentication.password}" "$SALT")

      # Use SQLite to modify the database
      sqlite3 "${cfg.stateDir}/radarr.db" <<EOF
      BEGIN TRANSACTION;
      DELETE FROM Users;
      INSERT INTO Users (Identifier, Username, Password, Salt, Iterations) VALUES ('$(uuidgen)', '${cfg.authentication.username}', '$HASH', '$SALT', 10000);
      COMMIT;
      EOF

      # Ensure proper permissions
      chown radarr:media "${cfg.stateDir}/radarr.db"
      chmod 600 "${cfg.stateDir}/radarr.db"
    '';
  };
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
      type = types.strMatching "(^$|^/.*)";
      default = "";
      example = "/radarr";
      description = mdDoc
        "URL base for reverse proxy support (must be empty or start with /)";
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
        type = types.addCheck types.str (str: str != "");
        default = "password";
        description = mdDoc "Password for web interface access";
      };
    };

    logLevel = mkOption {
      type = types.enum [ "Trace" "Debug" "Info" "Warn" "Error" ];
      default = "Info";
      example = "Debug";
      description = mdDoc ''
        Logging verbosity level.
        - Trace: Most verbose, includes detailed debug information
        - Debug: Includes debugging information
        - Info: Normal operational messages
        - Warn: Warning messages only
        - Error: Error messages only
      '';
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
        ExecStartPre = "${preStartScript}/bin/configure-radarr";
      };
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
