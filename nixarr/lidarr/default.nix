{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixarr.lidarr;
  dnsServers = config.lib.vpn.dnsServers;
  nixarr = config.nixarr;
in {
  options.nixarr.lidarr = {
    enable = mkEnableOption "Enable the Lidarr service.";

    stateDir = mkOption {
      type = types.path;
      default = "${nixarr.stateDir}/nixarr/lidarr";
      description = "The state directory for Lidarr";
    };

    vpn.enable = mkEnableOption ''
      Route Lidarr traffic through the VPN. Requires that `nixarr.vpn`
      is configured
    '';
  };

  config = mkIf cfg.enable {
    services.lidarr = {
      enable = cfg.enable;
      user = "lidarr";
      group = "media";
      dataDir = cfg.stateDir;
    };

    util.vpnnamespace.portMappings = [
      (
        mkIf cfg.vpn.enable {
          From = defaultPort;
          To = defaultPort;
        }
      )
    ];

    containers.lidarr = mkIf cfg.vpn.enable {
      autoStart = true;
      ephemeral = true;
      extraFlags = ["--network-namespace-path=/var/run/netns/wg"];

      bindMounts = {
        "${nixarr.mediaDir}".isReadOnly = false;
        "${cfg.stateDir}".isReadOnly = false;
      };

      config = {
        users.groups.media = {
          gid = config.users.groups.media.gid;
        };
        users.users.lidarr = {
          uid = lib.mkForce config.users.users.lidarr.uid;
          isSystemUser = true;
          group = "media";
        };

        # Use systemd-resolved inside the container
        # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
        networking.useHostResolvConf = lib.mkForce false;
        services.resolved.enable = true;
        networking.nameservers = dnsServers;

        services.lidarr = {
          enable = true;
          group = "media";
          dataDir = "${cfg.stateDir}";
        };

        system.stateVersion = "23.11";
      };
    };

    services.nginx = mkIf cfg.vpn.enable {
      enable = true;

      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;

      virtualHosts."127.0.0.1:${builtins.toString defaultPort}" = {
        listen = [
          {
            addr = "0.0.0.0";
            port = defaultPort;
          }
        ];
        locations."/" = {
          recommendedProxySettings = true;
          proxyWebsockets = true;
          proxyPass = "http://192.168.15.1:${builtins.toString defaultPort}";
        };
      };
    };
  };
}