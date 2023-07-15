{ pkgs, ... }: {
  imports = [ ./hardware.nix ../configuration.nix ];

  networking = {
    hostName = "jester";
    networkmanager.enable = true;
  };

  services.xserver.libinput.enable = true;

  environment.systemPackages = with pkgs; [
    linuxPackages_latest.perf
    libva-utils
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  machine.graphical = {
    enable = true;
    wm = "river";
  };

  system.stateVersion = "22.11";
}
