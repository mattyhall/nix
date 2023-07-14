{ pkgs, lib, ... }:
let
  config = {
    machine = {
      hostname = "jester";

      graphical.enable = true;

      extra-packages = with pkgs; [ linuxPackages_latest.perf libva-utils ];

      extra = {
        boot.loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };

        # Enable touchpad support (enabled default in most desktopManager).
        services.xserver.libinput.enable = true;
      };
    };
  };
in {
  imports = [
    ./jester-hardware-configuration.nix

    (import ./configuration.nix { inherit lib pkgs config; })
  ];
}
