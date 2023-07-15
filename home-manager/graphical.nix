{...}: {
  xdg.configFile."river/init" = {
    source = ./extra/river;
    executable = true;
  };

  programs = {
    waybar = {
      enable = true;

      settings = {
        bar = {
          layer = "top";
          position = "top";
          height = 24;

          modules-left = ["river/tags"];
          modules-center = ["river/window"];
          modules-right = ["pulseaudio" "network" "cpu" "memory" "battery" "clock"];

          cpu.format = "{usage}% ";
          memory.format = "{}% ";
          battery = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{capacity}% {icon}";
            format-icons = ["" "" "" "" ""];
          };
          network = {
            format-wifi = "{essid} ({signalStrength}%) ";
            format-ethernet = "{ifname}: {ipaddr}/{cidr} ";
            format-disconnected = "Disconnected ⚠";
          };
          pulseaudio = {
            format = "{volume}% {icon}";
            format-bluetooth = "{volume}% {icon}";
            format-muted = "";
            format-icons = {
              headphones = "";
              handsfree = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = ["" ""];
            };
            on-click = "pavucontrol";
          };
        };
      };

      style = builtins.readFile ./extra/waybar/style.css;
    };

    foot = {
      enable = true;
      settings = {
        main.font = "BerkeleyMono-Regular:size=7";

        cursor.color = "0e1419 f19618";
        colors = {
          background = "0e1419";
          foreground = "e5e1cf";
          regular0 = "000000";
          regular1 = "ff3333";
          regular2 = "b8cc52";
          regular3 = "e6c446";
          regular4 = "36a3d9";
          regular5 = "f07078";
          regular6 = "95e5cb";
          bright7 = "ffffff";
          bright0 = "323232";
          bright1 = "ff6565";
          bright2 = "e9fe83";
          bright3 = "fff778";
          bright4 = "68d4ff";
          bright5 = "ffa3aa";
          bright6 = "c7fffc";
        };
      };
    };
  };
}
