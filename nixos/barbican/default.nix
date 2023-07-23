{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./hardware.nix
    ../configuration.nix
    ../monitoring.nix
    ./monitoring.nix
  ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
  };

  networking.hostName = "barbican";

  machine.graphical = {
    enable = true;
    wm = "xfce";
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  users.users."mjh".openssh.authorizedKeys.keys = [
    (builtins.readFile ../../keys/rocket.pub)
    (builtins.readFile ../../keys/jester.pub)
  ];

  virtualisation.docker = {
    enable = true;
    daemon.settings = {dns = ["192.168.1.147" "8.8.8.8"];};
  };

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
  };

  # services.navidrome = {
  #   enable = true;
  #   settings = {
  #     MusicFolder = "/run/media/mjh/ddf2e11c-7aa4-4833-9cfc-8c84e9a453f9/music/";
  #     Port = 4533;
  #     Address = "0.0.0.0";
  #   };
  # };

  services.nginx = {
    enable = true;

    virtualHosts."dns.barbican.local".locations."/".proxyPass = "http://127.0.0.1:8000";
    virtualHosts."films.barbican.local".locations."/".proxyPass = "http://127.0.0.1:7878";
    virtualHosts."tv.barbican.local".locations."/".proxyPass = "http://127.0.0.1:8989";
    virtualHosts."jellyfin.barbican.local".locations."/".proxyPass = "http://127.0.0.1:8096";
    virtualHosts."prometheus.barbican.local".locations."/".proxyPass = "http://127.0.0.1:${toString config.services.prometheus.port}";
    # virtualHosts."music.barbican.local".locations."/".proxyPass = "http://127.0.0.1:${toString config.services.navidrome.settings.Port}";

    virtualHosts."${config.services.grafana.settings.server.domain}".locations."/" = {
      proxyPass = "http://127.0.0.1:${
        toString config.services.grafana.settings.server.http_port
      }";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
      '';
    };

    virtualHosts."qbit.barbican.local".locations."/".return = "301 http://192.168.1.147:8080";
  };

  networking.firewall.allowedTCPPorts = [80 3389 4533];

  system.stateVersion = "22.05";
}
