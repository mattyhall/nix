{ pkgs, config, lib, ... }:
let cfg = config.machine.graphical;
in {
  options.machine.graphical = {
    enable = lib.mkEnableOption "graphical";

    wm = lib.mkOption {
      type = lib.types.enum [ "river" ];
      default = "river";
      description = "the window manager to use";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      environment.systemPackages = with pkgs; [
        firefox
        pavucontrol
        xfce.thunar
        gnome3.eog
      ];

      hardware.opengl = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver
          vaapiIntel
          vaapiVdpau
          libvdpau-va-gl
        ];
      };

      fonts.fontDir.enable = true;
      fonts.fonts = with pkgs; [
        fira-code
        fira-code-symbols
        (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
      ];
    }

    (lib.mkIf (cfg.wm == "river") {
      environment.systemPackages = with pkgs; [
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
      ];
      security.pam.services.swaylock = { };

      programs.light.enable = true;

      programs.dconf.enable = true;

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
    })
  ]);
}
