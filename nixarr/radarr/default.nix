{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nixarr.radarr;
  nixarr = config.nixarr;
in {
  options.nixarr.radarr = {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = ''
        Whether or not to enable the Radarr service.

        **Required options:** [`nixarr.enable`](#nixarr.enable)
      '';
    };

    package = mkPackageOption pkgs "radarr" {};

    stateDir = mkOption {
      type = types.path;
      default = "${nixarr.stateDir}/radarr";
      defaultText = literalExpression ''"''${nixarr.stateDir}/radarr"'';
      example = "/nixarr/.state/radarr";
      description = ''
        The location of the state directory for the Radarr service.

        > **Warning:** Setting this to any path, where the subpath is not
        > owned by root, will fail! For example:
        >
        > ```nix
        >   stateDir = /home/user/nixarr/.state/radarr
        > ```
        >
        > Is not supported, because `/home/user` is owned by `user`.
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      defaultText = literalExpression ''!nixarr.radarr.vpn.enable'';
      default = !cfg.vpn.enable;
      example = true;
      description = "Open firewall for Radarr";
    };

    vpn.enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = ''
        **Required options:** [`nixarr.vpn.enable`](#nixarr.vpn.enable)

        Route Radarr traffic through the VPN.
      '';
    };

    port = mkOption {
      type = types.int;
      default = 7878;
      example = 7878;
      description = mdDoc "Port for the Radarr web interface";
    };

    authentication = {
      useFormLogin = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc "Whether to use a login page for authentication";
      };

      disabledForLocalAddresses = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc "Whether authentication is disabled for local addresses";
      };

      username = mkOption {
        type = types.str;
        default = "admin";
        description = "Username for web interface access";
      };

      password = mkOption {
        type = types.str;
        default = "changeme";
        description = mdDoc "Password for web interface access";
      };
    };

    logLevel = mkOption {
      type = types.enum ["debug" "info" "warn" "error"];
      default = "debug";
      description = mdDoc "Log level for Radarr";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enable -> nixarr.enable;
        message = ''
          The nixarr.radarr.enable option requires the
          nixarr.enable option to be set, but it was not.
        '';
      }
      {
        assertion = cfg.vpn.enable -> nixarr.vpn.enable;
        message = ''
          The nixarr.radarr.vpn.enable option requires the
          nixarr.vpn.enable option to be set, but it was not.
        '';
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

    systemd.services.radarr.preStart = let
      configTemplate = let
        port = toString cfg.port;
        apiKey = "$(head -c 32 /dev/urandom | base64 | tr -d '/+' | cut -c -32)";
        authenticationMethod =
          if cfg.authentication.useFormLogin
          then "Forms"
          else "Basic";
        authenticationRequired =
          if cfg.authentication.disabledForLocalAddresses
          then "DisabledForLocalAddresses"
          else "Enabled";
        logLevel = cfg.logLevel;
      in ''
        <?xml version="1.0"?>
        <Config>
          <BindAddress>*</BindAddress>
          <Port>${port}</Port>
          <SslPort>9898</SslPort>
          <EnableSsl>False</EnableSsl>
          <LaunchBrowser>True</LaunchBrowser>
          <ApiKey>${apiKey}</ApiKey>
          <AuthenticationMethod>${authenticationMethod}</AuthenticationMethod>
          <AuthenticationRequired>${authenticationRequired}</AuthenticationRequired>
          <Branch>master</Branch>
          <LogLevel>${logLevel}</LogLevel>
          <UrlBase></UrlBase>
          <InstanceName>Radarr</InstanceName>
        </Config>
      '';
    in ''
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
    '';

    # Enable and specify VPN namespace to confine service in.
    systemd.services.radarr.vpnConfinement = mkIf cfg.vpn.enable {
      enable = true;
      vpnNamespace = "wg";
    };

    # Port mappings
    vpnNamespaces.wg = mkIf cfg.vpn.enable {
      portMappings = [
        {
          from = cfg.port;
          to = cfg.port;
        }
      ];
    };

    services.nginx = mkIf cfg.vpn.enable {
      enable = true;

      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;

      virtualHosts."127.0.0.1:${builtins.toString cfg.port}" = {
        listen = [
          {
            addr = "0.0.0.0";
            port = cfg.port;
          }
        ];
        locations."/" = {
          recommendedProxySettings = true;
          proxyWebsockets = true;
          proxyPass = "http://192.168.15.1:${builtins.toString cfg.port}";
        };
      };
    };
  };
}