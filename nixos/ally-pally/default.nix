{modulesPath, ...}: {
  imports = [
    ../configuration.nix
    ../monitoring.nix
    ./hardware.nix
    "${modulesPath}/profiles/qemu-guest.nix"
  ];

  networking.hostName = "ally-pally";

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  services.prometheus.exporters.node.openFirewall = true;
  services.prometheus.exporters.process.openFirewall = true;

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

  services.nginx = {
    enable = true;

    virtualHosts."mattjhall.xyz" = {
      root = "/var/www/";

      addSSL = true;
      sslCertificate = "/etc/certs/mattjhall.xyz.pem";
      sslCertificateKey = "/etc/certs/mattjhall.xyz.key";
    };
  };

  networking.firewall.allowedTCPPorts = [80 443];

  system.stateVersion = "23.05";
}
