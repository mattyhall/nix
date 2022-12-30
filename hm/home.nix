{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "mjh";
  home.homeDirectory = "/home/mjh";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "hx";
  };

  home.packages = with pkgs; [
    ripgrep
    fd
    httpie
    jq
    delta
    htop
    openssh
    less
  ];
  
  gtk = {
    enable = true;
    theme = {
      name = "Ayu-Dark";
      package = pkgs.ayu-theme-gtk;
    };
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    defaultCommand = "fd --type f";
  };
  
  xdg.configFile."kak-lsp/kak-lsp.toml".source = ./extra/kak/kak-lsp.toml;
  xdg.configFile."kak/colors/dracula.kak".source = ./extra/kak/dracula.kak;
  xdg.configFile."kak/colors/dracula-transparent.kak".source = ./extra/kak/dracula-transparent.kak;
  programs.kakoune = {
    enable = true;

    config = {
      keyMappings = [
        # leader
        { mode = "normal"; key = "<space>"; effect = ","; docstring = "leader"; }
        { mode = "normal"; key = "<backspace>"; effect = "<space>"; docstring = "remove all selections but main"; }
        { mode = "normal"; key = "<a-backspace>"; effect = "<a-space>"; docstring = "remove main selection"; }

        # splits
        { mode = "normal"; key = "<c-w>"; effect = ":enter-user-mode<space>splits<ret>"; docstring = "enter splits mode"; }
        { mode = "splits"; key = "s"; effect = ":vsplit<ret>"; docstring = "split vertically"; }
        { mode = "splits"; key = "v"; effect = ":hsplit<ret>"; docstring = "split horizontally"; }
        { mode = "splits"; key = "c"; effect = ":quit!<ret>"; docstring = "quit"; }

        # fzf
        { mode = "user"; key = "/"; effect = ":fzf-mode<ret>g"; docstring = "grep"; }
        { mode = "user"; key = "<space>"; effect = ":fzf-mode<ret>v"; docstring = "find files (vcs)"; }
        { mode = "user"; key = "f"; effect = ":fzf-mode<ret>f"; docstring = "find files"; }
        { mode = "user"; key = ","; effect = ":fzf-mode<ret>b"; docstring = "find buffers"; }
      ];

      numberLines = {
        enable = true;
        relative = true;
        highlightCursor = true;
      };

      colorScheme = "dracula";
    };

    plugins = with pkgs.kakounePlugins; [
        kak-lsp
        fzf-kak
        powerline-kak
    ];
  
    extraConfig = ''
      # splits
      define-command -docstring "vsplit <filename>: open file in vertical tmux split" \
      vsplit -params 0.. -file-completion %{
        tmux-terminal-vertical kak -c %val{session} %arg{@}
      }
      define-command -docstring "hsplit <filename>: open file in horizontal tmux split" \
      hsplit -params 0.. -file-completion %{
        tmux-terminal-horizontal kak -c %val{session} %arg{@}
      }

      # lsp
      eval %sh{kak-lsp --kakoune -s $kak_session}
      lsp-enable
      map global user c %{: enter-user-mode lsp<ret>} -docstring "LSP mode"

      # powerline
      powerline-start

      # rulers
      add-highlighter global/ column 50 default,rgb:44475a
      add-highlighter global/ column 72 default,rgb:44475a
      add-highlighter global/ column 120 default,rgb:44475a
    '';
  };

  programs.helix = {
    enable = true;

    languages = [
      {
        name = "git-commit";
        rulers = [50 72];
      }
    ];

    settings = {
      theme = "ayu_dark";
      editor = {
        true-color = true;
        line-number = "relative";
        scrolloff = 0;
        rulers = [80 120];

        statusline = {
          left = [
            "mode"
            "spinner"
          ];
          center = ["file-name"];
          right = [
            "diagnostics"
            "selections"
            "position"
            "position-percentage"
            "file-encoding"
            "file-type"
          ];
          separator = "│";
        };
        
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
      };
      
      keys = {
        normal = {
          H = "extend_char_left";
          L = "extend_char_right";
          J = "extend_line_down";
          K = "extend_line_up";

          W = "extend_next_word_start";
          B = "extend_prev_word_start";
          E = "extend_next_word_end";
          X = "extend_line_below";

          ";" = "keep_primary_selection";
          "," = "collapse_selection";

          A-J = "join_selections";

          A-k = "keep_selections";
          A-K = "remove_selections";

          N = "extend_search_next";
        
          space = {
            space = "file_picker";
            "," = "buffer_picker";
          
            c = {
              s = "symbol_picker";
              S = "workspace_symbol_picker";
              d = "diagnostics_picker";
              D = "workspace_diagnostics_picker";
              R = "rename_symbol";
              a = "code_action";
            };
          };
        };
      };
    };
  };

  programs.tmux = {
    enable = true;

    shortcut = "a";

    keyMode = "vi";
    customPaneNavigationAndResize = true;

    escapeTime = 0;

    extraConfig = ''
        # tmux zoom
        bind C-z run "tmux-zoom.sh"

        # command prompt
        bind : command-prompt

        # easy-to-remember split pane commands
        bind | split-window -h
        bind - split-window -v
        unbind '"'
        unbind %

        # status line
        set -g status-style bg=default,fg=colour12
        set -g status-justify left
        set -g status-interval 2

        # window mode
        setw -g mode-style bg=colour6,fg=colour0

        # window status
        setw -g window-status-format "#[fg=magenta]#[bg=black] #I #[bg=cyan]#[fg=colour8] #W "
        setw -g window-status-current-format "#[bg=brightmagenta]#[fg=colour8] #I #[fg=colour8]#[bg=colour14] #W "
        set -g window-status-current-style bg=colour0,fg=colour11,dim
        setw -g window-status-style bg=green,fg=black,reverse

        # Info on left (I don't have a session display for now)
        set -g status-left ""

        # quieten
        set-option -g visual-activity off
        set-option -g visual-bell off
        set-option -g visual-silence off
        set-window-option -g monitor-activity off
        set-option -g bell-action none

        # tmux clock
        set -g clock-mode-colour blue

        # kill pane changes
        bind x kill-pane
        bind X next-layout

        # urxvt tab like window switching (-n: no prior escape seq)
        bind -n S-down new-window
        bind -n S-left prev
        bind -n S-right next

        # modes
        setw -g clock-mode-colour colour135
        set -g mode-style fg=colour196,bg=colour238,bold

        # panes
        set -g pane-border-style bg=colour236,bg=colour238
        set -g pane-active-border-style bg=colour236,fg=colour3

        # statusbar
        set -g status-position bottom
        set -g status-style bg=colour239,fg=colour12,dim
        set -g status-left ""
        set -g status-right "#[fg=colour233,bg=colour241,bold] %d/%m #[fg=colour233,bg=colour245,bold] %H:%M:%S "
        set -g status-right-length 50
        set -g status-left-length 20

        setw -g window-status-current-style fg=colour0,bg=colour6,bold
        setw -g window-status-current-format ' #I#[fg=colour239]:#[fg=colour239]#W#[fg=colour50]#F '

        setw -g window-status-style fg=colour138,bg=colour238,none
        setw -g window-status-format ' #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F '

        setw -g window-status-bell-style fg=colour255,bg=colour1,bold

        # messages
        set -g message-style fg=colour232,bg=colour166,bold

        # Don't let zsh rename the pane
        set -g allow-rename off

        set -g default-terminal screen-256color
        # set-option -g terminal-overrides 'xterm*:smcup@:rmcup@'
        set -ga terminal-overrides ",*col*:Tc"

        set -g mouse on
        bind -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'select-pane -t=; copy-mode -e; send-keys -M'"
        bind -n WheelDownPane select-pane -t= \; send-keys -M
        bind -n C-WheelUpPane select-pane -t= \; copy-mode -e \; send-keys -M
        bind -T copy-mode-vi    C-WheelUpPane   send-keys -X halfpage-up
        bind -T copy-mode-vi    C-WheelDownPane send-keys -X halfpage-down
        bind -T copy-mode-emacs C-WheelUpPane   send-keys -X halfpage-up
        bind -T copy-mode-emacs C-WheelDownPane send-keys -X halfpage-down

        bind -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "xclip -i -f -selection primary | xclip -i -selection clipboard"
    '';
  };

  programs.git = {
    enable = true;

    userName = "Matt Hall";
    userEmail = "matthew@quickbeam.me.uk";

    delta.enable = true;

    extraConfig = {
        merge = {
          conflictStyle = "diff3";
        };

        init = {
          defaultBranch = "main";
        };
    };
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fish = {
    enable = true;

    shellInit = ''
    direnv hook fish | source
    '';

    shellAliases = {
      gs = "git status";
      gb = "git branch | fzf | git switch";
      e = "$EDITOR";
    };
  };
  
  xdg.configFile."river/init".source = ./extra/river;
  xdg.configFile."river/init".executable = true;

  programs.foot = {
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
  
  programs.waybar = {
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
        memory.format =  "{}% ";
        battery = {
          states = { warning = 30; critical = 15; };
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
    style = ''
* {
  font-family: "Berkeley Mono";
  min-height: 0px;
  font-size: 12px;
}

window#waybar {
  background: transparent;
  color: white;
}

#tags button {
  color: white;
  background: transparent;
  margin: 1px 2px;
  padding: 1px 2px;
}

#tags button.focused {
  color: #FFB454;
}

#clock, #battery, #cpu, #memory, #network, #pulseaudio, #tray {
  padding: 0 3px;
  margin-right: 16px;
}     
    '';
  };
}
