{ config, pkgs, ... }:

{
  programs.fish.enable = true;
  environment.shells = with pkgs; [ fish ];

  users.users.mjh = {
    isNormalUser = true;
    home = "/home/mjh";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    shell = pkgs.fish;
  };

  nixpkgs.overlays = [
    (self: super: { nix-direnv = super.nix-direnv.override { enableFlakes = true; }; } )
  ];
}
