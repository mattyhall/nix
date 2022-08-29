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

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
  };

  users.users."mjh".openssh.authorizedKeys.keys = [
    # Rocket
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCyD73jJmK8hH+AcOzXiG5oNIm5t+XxVYcHY5Nect+yui3pYaKkh63dWl0jWOa/UzZhFj/UQqF22puseggPJ2FCH7PoNlXGwUQ7NTSu113U1ug5KupNpXQew8w1oprrBoeJi3Qx/5MtS7Rpv8x2Knw6TOPBaaIgnibz8BBdLald3vzyVqyBkV2Vx1lo+XCXrHkvr5K+BKrI2koSv80OValFAk3kS9i2AyxcPXmLiAOD8oC6ktg2Y5shm4GXDZjJ1eqiRHw7pyyRFSWO5dxznGq2F6F1VmlicoEmdJKahiogy+s+cDVf8lFgOBCVtnQDJ+iTwGJJfMHIdpVmNQYJw6e2iSAi0SWQIEZ9i7ojCg8BBhrskZc8uwpLzJtky+dkizz2CsZ62th/Q6vRVW6oTbL8l3U7iDE3q2p+51akAhPBsScvDRafG3+gJkw2F5FCm+NtfEgXQZHyG+Gp1lwjoJYhmQA3VI6fkrQHqInfaIHW+wI9WIT479fvbDQfRKVlAgM= mjh@DESKTOP-NJE68U1"
  ];

  virtualisation.docker.enable = true;

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
    ];
  };

  services.nginx = {
    enable = true;

    virtualHosts."dns.barbican.local".locations."/".proxyPass = "http://127.0.0.1:8000";
    virtualHosts."films.barbican.local".locations."/".proxyPass = "http://127.0.0.1:7878";
    virtualHosts."tv.barbican.local".locations."/".proxyPass = "http://127.0.0.1:8989";
    virtualHosts."jellyfin.barbican.local".locations."/".proxyPass = "http://127.0.0.1:8096";
    virtualHosts."grafana.barbican.local".locations."/".proxyPass = "http://127.0.0.1:3000";

    virtualHosts."qbit.barbican.local".locations."/".return = "301 http://192.168.1.147:8080";
  };

  networking.firewall.allowedTCPPorts = [ 80 ];

  system.stateVersion = "22.05"; # Did you read the comment?
}

