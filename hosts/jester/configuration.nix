# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let 
  unstable = import <nixos-unstable> {};
  newRiver = (pkgs.river.overrideAttrs (old: {
    version = "0.2-dev-001";
    src = pkgs.fetchFromGitHub {
      owner = "riverwm";
      repo = "river";
      rev = "e603c5460a27bdc8ce6c32c8ee5e53fb789bc10b";
      sha256 = "sha256-x971VRWp72uNRNcBTU2H81EiqWa5kg0E5n7tK8ypaQM=";
      fetchSubmodules = true;      
    };
  })).override { 
    wlroots = unstable.wlroots_0_16;
     xwaylandSupport = true;
   };
in {
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      ../common.nix
    ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      options = "--delete-older-than 8d";
    };
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "jester"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  security.pam.services.swaylock = {};

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  hardware.opengl.enable = true;

  environment.systemPackages = with pkgs; [
    vim 
    git
    fish
    firefox
    pavucontrol
    direnv

    newRiver
    mako # notifs
    swayidle
    swaylock
    swaybg
    waybar 
    fuzzel # launcher
    wl-clipboard
  ];
  
  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
    fira-code
    fira-code-symbols
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
