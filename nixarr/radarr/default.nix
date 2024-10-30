{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.nixarr.radarr;
  nixarr = config.nixarr;
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

    # systemd.services.radarr = {
    #   preStart = ''
    #     # Ensure state directory exists with correct permissions
    #     mkdir -p ${cfg.stateDir}
    #     chown radarr:media ${cfg.stateDir}
    #     chmod 750 ${cfg.stateDir}

    #     # Generate secure random values
    #     API_KEY=$(head -c 32 /dev/urandom | base64 | tr -d '/+' | cut -c -32)

    #     # Write config file
    #     cat > ${cfg.stateDir}/config.xml <<EOF
    #     <Config>
    #       <BindAddress>*</BindAddress>
    #       <Port>${toString cfg.port}</Port>
    #       <SslPort>9898</SslPort>
    #       <EnableSsl>False</EnableSsl>
    #       <LaunchBrowser>True</LaunchBrowser>
    #       <ApiKey>$API_KEY</ApiKey>
    #       <AuthenticationMethod>None</AuthenticationMethod>
    #       <AuthenticationRequired>${
    #         if cfg.authentication.disabledForLocalAddresses then
    #           "DisabledForLocalAddresses"
    #         else
    #           "Enabled"
    #       }</AuthenticationRequired>
    #       <Branch>master</Branch>
    #       <LogLevel>${cfg.logLevel}</LogLevel>
    #       <UrlBase>${cfg.urlBase}</UrlBase>
    #       <InstanceName>Radarr</InstanceName>
    #     </Config>
    #     EOF

    #     # Set correct permissions
    #     chown radarr:media ${cfg.stateDir}/config.xml
    #     chmod 600 ${cfg.stateDir}/config.xml
    #   '';
    # };

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
