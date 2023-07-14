{ pkgs, ... }: {
  imports =
    [ ./jester-hardware-configuration.nix ./configuration.nix ./graphical.nix ];

  networking.hostName = "jester";
  services.xserver.libinput.enable = true;

  environment.systemPackages = with pkgs; [
    linuxPackages_latest.perf
    libva-utils
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
}
