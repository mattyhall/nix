{ pkgs, lib, ... }:
let base-cfg = import ./configuration.nix;
in {
  imports = [
    ./jester-hardware-configuration.nix

    (base-cfg {
      inherit lib pkgs;

      config.machine = {
        hostname = "jester";

        extra-packages = with pkgs; [
          firefox
          pavucontrol
          direnv

          xfce.thunar
          gnome3.eog

          linuxPackages_latest.perf

          river
          mako # notifs
          swayidle
          swaylock
          swaybg
          waybar
          fuzzel # launcher
          wl-clipboard
          greetd.tuigreet
          slurp
          wayshot

          libva-utils
        ];

        extra = {
          boot.loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
          };

          security.pam.services.swaylock = { };

          # Enable touchpad support (enabled default in most desktopManager).
          services.xserver.libinput.enable = true;

          hardware.opengl = {
            enable = true;
            extraPackages = with pkgs; [
              intel-media-driver
              vaapiIntel
              vaapiVdpau
              libvdpau-va-gl
            ];
          };

          programs.light.enable = true;

          programs.dconf.enable = true;

          fonts.fontDir.enable = true;
          fonts.fonts = with pkgs; [
            fira-code
            fira-code-symbols
            (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
          ];

          services.greetd = {
            enable = true;
            settings = {
              default_session = {
                command =
                  "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd river";
                user = "mjh";
              };
            };
          };
        };
      };
    })
  ];
}
