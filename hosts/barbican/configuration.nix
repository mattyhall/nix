# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      ../common.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      experimental-features = nix-command flakes
    '';
  };

  networking.hostName = "barbican";

  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_GB.UTF-8";

  services.xserver.enable = true;

  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.displayManager.defaultSession = "xfce";

  environment.systemPackages = with pkgs; [
    vim 
    git
    fish
    firefox
  ];

  services.openssh.enable = true;

  system.stateVersion = "22.05"; # Did you read the comment?

}

