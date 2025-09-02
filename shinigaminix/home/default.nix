{ config, lib, pkgs, inputs, ... }:

{
  # Home Manager configuration for user 'reaper'
  
  home = {
    username = "reaper";
    homeDirectory = "/home/reaper";
    stateVersion = "24.05";
  };

  # User packages (in addition to system packages)
  home.packages = with pkgs; [
    # Development user tools
    gh              # GitHub CLI
    gitui           # Git UI
    lazygit         # Git UI alternative
    
    # Personal productivity
    firefox         # Primary browser
    thunderbird     # Email client
    
    # Communication
    slack
    discord
    signal-desktop
    
    # Media
    spotify
    vlc
    mpv
    
    # Office suite
    libreoffice
    
    # Graphics
    gimp
    inkscape
    
    # Password management
    bitwarden
    
    # Note taking
    obsidian
    logseq
    
    # File sync
    syncthing
    
    # Archive manager
    p7zip
    unrar
    
    # System monitoring
    htop
    btop
    
    # Terminal utilities
    neofetch
    fastfetch
  ];

  # Git configuration
  programs.git = {
    enable = true;
    userName = "reaper";
    userEmail = "reaper@osiris-adelie.ts.net"; # Update with your actual email
    
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
      
      # Delta for better diffs
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta = {
        navigate = true;
        light = false;
        side-by-side = true;
      };
      
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };
  };

  # Shell configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    
    shellAliases = {
      # System
      ll = "eza -la";
      la = "eza -la";
      ls = "eza";
      cat = "bat";
      cd = "z";
      
      # Git
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      
      # NixOS
      rebuild = "sudo nixos-rebuild switch --flake /home/reaper/shinigaminix";
      update = "cd /home/reaper/shinigaminix && nix flake update";
      
      # Development
      v = "nvim";
      e = "nvim";
    };
    
    initExtra = ''
      # Initialize tools
      eval "$(zoxide init zsh)"
      eval "$(starship init zsh)"
      
      # Custom functions
      mkcd() { mkdir -p "$1" && cd "$1"; }
    '';
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      format = lib.concatStrings [
        "$directory"
        "$git_branch"
        "$git_status"
        "$nix_shell"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];
      
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      
      directory = {
        style = "bold blue";
        truncation_length = 3;
        fish_style_pwd_dir_length = 1;
      };
      
      git_branch = {
        style = "bold purple";
      };
      
      nix_shell = {
        format = "via [$symbol$state]($style) ";
        symbol = "❄️ ";
        style = "bold blue";
      };
    };
  };

  # Terminal configuration
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        opacity = 0.9;
        decorations = "none";
        startup_mode = "Windowed";
        title = "Alacritty";
        class = {
          instance = "Alacritty";
          general = "Alacritty";
        };
      };
      
      font = {
        normal = {
          family = "FiraCode Nerd Font Mono";
          style = "Regular";
        };
        bold = {
          family = "FiraCode Nerd Font Mono";
          style = "Bold";
        };
        italic = {
          family = "FiraCode Nerd Font Mono";
          style = "Italic";
        };
        size = 12.0;
      };
      
      cursor = {
        style = {
          shape = "Block";
          blinking = "Off";
        };
      };
      
      selection = {
        save_to_clipboard = true;
      };
    };
  };

  # Hyprland configuration
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    
    settings = {
      # Monitor configuration (adjust for your setup)
      monitor = [
        "eDP-1,2256x1504@60,0x0,1.25"  # Framework 13 internal display
        ",preferred,auto,1"              # External monitors
      ];
      
      # Environment variables
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "QT_QPA_PLATFORM,wayland"
        "SDL_VIDEODRIVER,wayland"
        "GDK_BACKEND,wayland,x11"
      ];
      
      # Input configuration
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          tap-to-click = true;
          scroll_factor = 0.5;
        };
        sensitivity = 0;
      };
      
      # General settings
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
        allow_tearing = false;
      };
      
      # Decoration
      decoration = {
        rounding = 8;
        blur = {
          enabled = true;
          size = 8;
          passes = 1;
          vibrancy = 0.1696;
        };
        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
      };
      
      # Animations
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };
      
      # Layout
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };
      
      # Window rules
      windowrulev2 = [
        # Gaming optimizations
        "immediate,class:^(steam_app_).*"
        "fullscreen,class:^(steam_app_).*"
        "noinitialfocus,class:^(steam_app_).*"
        
        # Development
        "workspace 2,class:^(code).*"
        "workspace 3,class:^(firefox).*"
        
        # Communication
        "workspace 9,class:^(discord).*"
        "workspace 9,class:^(slack).*"
        
        # Media
        "workspace 8,class:^(spotify).*"
        
        # Float specific windows
        "float,class:^(pavucontrol).*"
        "float,class:^(blueman-manager).*"
        "float,class:^(nm-applet).*"
      ];
      
      # Keybindings
      bind = [
        # Basic window management
        "SUPER, Return, exec, alacritty"
        "SUPER, Q, killactive"
        "SUPER, M, exit"
        "SUPER, E, exec, thunar"
        "SUPER, V, togglefloating"
        "SUPER, R, exec, rofi -show drun"
        "SUPER, P, pseudo"
        "SUPER, J, togglesplit"
        
        # Move focus
        "SUPER, left, movefocus, l"
        "SUPER, right, movefocus, r"
        "SUPER, up, movefocus, u"
        "SUPER, down, movefocus, d"
        "SUPER, h, movefocus, l"
        "SUPER, l, movefocus, r"
        "SUPER, k, movefocus, u"
        "SUPER, j, movefocus, d"
        
        # Switch workspaces
        "SUPER, 1, workspace, 1"
        "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3"
        "SUPER, 4, workspace, 4"
        "SUPER, 5, workspace, 5"
        "SUPER, 6, workspace, 6"
        "SUPER, 7, workspace, 7"
        "SUPER, 8, workspace, 8"
        "SUPER, 9, workspace, 9"
        "SUPER, 0, workspace, 10"
        
        # Move windows to workspaces
        "SUPER SHIFT, 1, movetoworkspace, 1"
        "SUPER SHIFT, 2, movetoworkspace, 2"
        "SUPER SHIFT, 3, movetoworkspace, 3"
        "SUPER SHIFT, 4, movetoworkspace, 4"
        "SUPER SHIFT, 5, movetoworkspace, 5"
        "SUPER SHIFT, 6, movetoworkspace, 6"
        "SUPER SHIFT, 7, movetoworkspace, 7"
        "SUPER SHIFT, 8, movetoworkspace, 8"
        "SUPER SHIFT, 9, movetoworkspace, 9"
        "SUPER SHIFT, 0, movetoworkspace, 10"
        
        # Screenshots
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        "SHIFT, Print, exec, grim - | wl-copy"
        
        # Media keys
        ", XF86AudioRaiseVolume, exec, pamixer -i 5"
        ", XF86AudioLowerVolume, exec, pamixer -d 5"
        ", XF86AudioMute, exec, pamixer -t"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        
        # Brightness
        ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        
        # Lock screen
        "SUPER, L, exec, hyprlock"
        
        # Gaming mode toggle
        "SUPER SHIFT, G, exec, gamemoderun"
      ];
      
      # Mouse bindings
      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];
      
      # Startup applications
      exec-once = [
        "waybar"
        "mako"
        "hyprpaper"
        "hypridle"
        "nm-applet"
        "blueman-applet"
        "wl-paste --watch cliphist store"
      ];
    };
  };

  # Waybar configuration
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 34;
        
        modules-left = [ "hyprland/workspaces" "hyprland/mode" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [ 
          "network" 
          "bluetooth"
          "pulseaudio" 
          "battery" 
          "clock" 
          "tray" 
        ];
        
        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{icon}";
          format-icons = {
            "1" = "󰣇";
            "2" = "";
            "3" = "";
            "4" = "";
            "5" = "";
            "6" = "";
            "7" = "";
            "8" = "󰝚";
            "9" = "󰙯";
            "10" = "";
          };
        };
        
        clock = {
          format = "{:%H:%M}";
          format-alt = "{:%A, %B %d, %Y (%R)}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
        };
        
        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% 󰂄";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          format-icons = [ "" "" "" "" "" ];
        };
        
        network = {
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "{ipaddr}/{cidr} 󰈀";
          tooltip-format = "{ifname} via {gwaddr} 󰈀";
          format-linked = "{ifname} (No IP) 󰈀";
          format-disconnected = "Disconnected ⚠";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
        };
        
        pulseaudio = {
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" "" ];
          };
          on-click = "pavucontrol";
        };
        
        bluetooth = {
          format = " {status}";
          format-connected = " {device_alias}";
          format-connected-battery = " {device_alias} {device_battery_percentage}%";
          tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
        };
        
        tray = {
          spacing = 10;
        };
      };
    };
    
    style = ''
      * {
        font-family: "FiraCode Nerd Font Mono";
        font-size: 13px;
      }
      
      window#waybar {
        background-color: rgba(43, 48, 59, 0.8);
        border-bottom: 3px solid rgba(100, 114, 125, 0.5);
        color: #ffffff;
        transition-property: background-color;
        transition-duration: .5s;
      }
      
      button {
        box-shadow: inset 0 -3px transparent;
        border: none;
        border-radius: 0;
      }
      
      #workspaces button {
        padding: 0 5px;
        background-color: transparent;
        color: #ffffff;
      }
      
      #workspaces button:hover {
        background: rgba(0, 0, 0, 0.2);
      }
      
      #workspaces button.active {
        background-color: #64727D;
        box-shadow: inset 0 -3px #ffffff;
      }
      
      #clock, #battery, #cpu, #memory, #disk, #temperature, #backlight, #network, #pulseaudio, #bluetooth, #tray {
        padding: 0 10px;
        color: #ffffff;
      }
      
      #battery.charging, #battery.plugged {
        color: #ffffff;
        background-color: #26A65B;
      }
      
      @keyframes blink {
        to {
          background-color: #ffffff;
          color: #000000;
        }
      }
      
      #battery.critical:not(.charging) {
        background-color: #f53c3c;
        color: #ffffff;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }
    '';
  };

  # Mako notification daemon
  services.mako = {
    enable = true;
    backgroundColor = "#1a1a1a";
    borderColor = "#74c7ec";
    borderRadius = 8;
    borderSize = 2;
    defaultTimeout = 5000;
    font = "FiraCode Nerd Font Mono 12";
    textColor = "#cdd6f4";
    width = 300;
    height = 100;
    margin = "10";
    padding = "15";
  };

  # XDG configuration
  xdg = {
    enable = true;
    
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${config.home.homeDirectory}/Desktop";
      documents = "${config.home.homeDirectory}/Documents";
      download = "${config.home.homeDirectory}/Downloads";
      music = "${config.home.homeDirectory}/Music";
      pictures = "${config.home.homeDirectory}/Pictures";
      videos = "${config.home.homeDirectory}/Videos";
      templates = "${config.home.homeDirectory}/Templates";
      publicShare = "${config.home.homeDirectory}/Public";
    };
    
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
      };
    };
  };

  # Enable Home Manager
  programs.home-manager.enable = true;
}
