{ pkgs, lib, config, ... }:
let cfg = config.machine.graphical;
in {
  options.machine.graphical = {
    enable = lib.mkEnableOption "Setup the machine for graphical interaction";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      firefox
      pavucontrol
      xfce.thunar
      gnome3.eog
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

    hardware.opengl = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };

    security.pam.services.swaylock = { };

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
}
