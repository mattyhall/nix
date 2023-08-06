{modulesPath, lumin, ...}: {
  imports = [
    ../configuration.nix
    ../monitoring.nix
    ./hardware.nix
    "${modulesPath}/profiles/qemu-guest.nix"
    lumin.nixosModule.aarch64-linux
  ];

  networking.hostName = "ally-pally";

  services.lumin = {
    enable = true;
    site = "/var/www/website-rewrite";
  };

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
      locations."/".proxyPass = "http://127.0.0.1:3000";

      addSSL = true;
      sslCertificate = "/etc/certs/mattjhall.xyz.pem";
      sslCertificateKey = "/etc/certs/mattjhall.xyz.key";
    };

    virtualHosts."mattjhall.co.uk" = {
      locations."/".proxyPass = "http://127.0.0.1:3000";

      addSSL = true;
      sslCertificate = "/etc/certs/mattjhall.co.uk.pem";
      sslCertificateKey = "/etc/certs/mattjhall.co.uk.key";
    };
  };

  networking.firewall.allowedTCPPorts = [80 443];

  system.stateVersion = "23.05";
}
