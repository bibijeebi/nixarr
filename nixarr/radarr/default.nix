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
    ];

    services.radarr = {
      enable = cfg.enable;
      package = cfg.package;
      user = "radarr";
      group = "media";
      openFirewall = cfg.openFirewall;
      dataDir = cfg.stateDir;
    };

    systemd.services.radarr = {
      preStart = let
        configTemplate = let
          port = toString cfg.port;
          authenticationMethod =
            if cfg.authentication.useFormLogin then "Forms" else "Basic";
          authenticationRequired =
            if cfg.authentication.disabledForLocalAddresses then
              "DisabledForLocalAddresses"
            else
              "Enabled";
        in ''
          <?xml version="1.0"?>
          <Config>
            <BindAddress>*</BindAddress>
            <Port>${port}</Port>
            <SslPort>9898</SslPort>
            <EnableSsl>False</EnableSsl>
            <LaunchBrowser>True</LaunchBrowser>
            <ApiKey>''${API_KEY}</ApiKey>
            <AuthenticationMethod>${authenticationMethod}</AuthenticationMethod>
            <AuthenticationRequired>${authenticationRequired}</AuthenticationRequired>
            <Branch>master</Branch>
            <LogLevel>${cfg.logLevel}</LogLevel>
            <UrlBase>${cfg.urlBase}</UrlBase>
            <InstanceName>Radarr</InstanceName>
          </Config>
        '';
      in ''
        # Generate API key
        API_KEY=$(head -c 32 /dev/urandom | base64 | tr -d '/+' | cut -c -32)

        configFile=${cfg.stateDir}/config.xml
        expectedConfig=$(cat << 'EOL'
        ${configTemplate}
        EOL
        )
        if [ ! -f $configFile ] || [ "$(cat $configFile)" != "$expectedConfig" ]; then
          echo "$expectedConfig" > $configFile
          chown radarr:media $configFile
          chmod 600 $configFile
        fi

        # Set up default user in SQLite database
        ${pkgs.sqlite}/bin/sqlite3 ${cfg.stateDir}/radarr.db << EOF
          INSERT OR REPLACE INTO Users (
            Id, Identifier, Username, Password, Salt
          ) VALUES (
            1,
            '$(uuidgen)',
            '${cfg.authentication.username}',
            '${cfg.authentication.password}',
            '$(head -c 16 /dev/urandom | base64)'
          );
        EOF
      '';

      # VPN confinement configuration
      vpnConfinement = mkIf cfg.vpn.enable {
        enable = true;
        vpnNamespace = "wg";
      };
    };

    # VPN namespace configuration
    vpnNamespaces.wg = mkIf cfg.vpn.enable {
      portMappings = [{
        from = cfg.port;
        to = cfg.port;
      }];
    };

    # Nginx reverse proxy for VPN setup
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
