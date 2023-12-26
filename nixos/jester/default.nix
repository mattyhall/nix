{pkgs, ...}: {
  imports = [./hardware.nix ../configuration.nix];

  nixpkgs.config.allowUnfree = true;

boot.kernelModules = [ "kvm-intel" ];

  networking = {
    hostName = "jester";
    networkmanager.enable = true;
  };

  services.xserver.libinput.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  environment.systemPackages = with pkgs; [
    linuxPackages_latest.perf
    libva-utils
    aerc
    weechat
    bitwarden-cli
    maestral
    jetbrains-toolbox
    cmake
    clang
    virt-manager
  ];

  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true; # virt-manager requires dconf to remember settings

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
