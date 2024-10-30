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
      '';
      deps = [ ];
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
