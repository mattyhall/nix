{pkgs, ...}: {
  imports = [./graphical.nix];

  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };

    settings = {
      keep-outputs = true;
      keep-derivations = true;
      experimental-features = ["nix-command" "flakes"];
    };
  };

  environment.pathsToLink = ["/share/nix-direnv"];

  programs.fish.enable = true;
  environment.shells = [pkgs.fish];

  users.users.mjh = {
    isNormalUser = true;
    home = "/home/mjh";
    extraGroups = ["wheel" "networkmanager" "docker" "video" "libvirtd"];
    shell = pkgs.fish;
  };

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    direnv
    nix-direnv

    neovim
    git
  ];
}
