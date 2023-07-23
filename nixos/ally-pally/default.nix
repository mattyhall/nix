{modulesPath, ...}: {
  imports = [
    ../configuration.nix
    ./hardware.nix
    "${modulesPath}/profiles/qemu-guest.nix"
  ];

  networking.hostName = "ally-pally";

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
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

  system.stateVersion = "23.05";
}
