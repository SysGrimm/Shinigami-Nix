{ config, lib, pkgs, inputs ? {}, ... }:

{
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    package = if inputs ? hyprland 
              then inputs.hyprland.packages.${pkgs.system}.hyprland
              else pkgs.hyprland;
    portalPackage = if inputs ? hyprland
                   then inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland
                   else pkgs.xdg-desktop-portal-hyprland;
  };

  # XDG portal configuration for Hyprland
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      (if inputs ? hyprland
       then inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland
       else pkgs.xdg-desktop-portal-hyprland)
      pkgs.xdg-desktop-portal-gtk
    ];
    configPackages = [
      (if inputs ? hyprland
       then inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland
       else pkgs.xdg-desktop-portal-hyprland)
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  # Enable Wayland support for various applications
  environment.sessionVariables = {
    # Cursor fixes for various hardware
    WLR_NO_HARDWARE_CURSORS = "1";
    XCURSOR_SIZE = "24";
    
    # Graphics compatibility
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
    WLR_DRM_NO_ATOMIC = "1";
    
    # Wayland app support
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    GDK_BACKEND = "wayland,x11";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    
    # Additional stability fixes
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    ANKI_WAYLAND = "1";
  };

  # Security for Hyprland
  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };

  # Essential packages for Hyprland
  environment.systemPackages = with pkgs; [
    # Hyprland ecosystem
    hyprpaper      # Wallpaper daemon
    hyprlock       # Screen locker
    hypridle       # Idle daemon
    hyprpicker     # Color picker
    hyprshot       # Screenshot utility
    
    # Wayland utilities
    wl-clipboard
    wlr-randr
    wayland
    wayland-protocols
    wayland-utils
    
    # Graphics compatibility tools
    mesa
    vulkan-tools
    glxinfo
    
    # Notifications
    mako
    libnotify
    
    # Application launcher
    rofi-wayland
    wofi
    
    # Status bar
    waybar
    
    # File manager
    xfce.thunar
    
    # Terminal
    foot
    alacritty
    kitty
    
    # Media
    mpv
    imv
    
    # System tools
    brightnessctl
    playerctl
    pamixer
    
    # Screenshots and screen recording
    grim
    slurp
    wf-recorder
    
    # Clipboard manager
    cliphist
    
    # Network
    networkmanagerapplet
    
    # Bluetooth
    blueman
    
    # Audio
    pavucontrol
    
    # System monitor
    btop
    
    # Theme tools
    nwg-look
    libsForQt5.qt5ct
    qt6ct
    
    # Fonts
    font-awesome
  ];

  # Services for Hyprland
  services = {
    # Display manager
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
          user = "greeter";
        };
      };
    };
    
    # Pipewire for audio
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    
    # dbus for desktop integration
    dbus.enable = true;
    
    # GVFS for trash and removable media
    gvfs.enable = true;
    
    # Tumbler for thumbnails
    tumbler.enable = true;
  };

  # Programs
  programs = {
    # thunar file manager
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
    
    # XWayland
    xwayland.enable = true;
  };

  # GTK configuration
  programs.dconf.enable = true;
  
  # Qt configuration
  qt = {
    enable = true;
    platformTheme = lib.mkDefault "qt5ct";
    style = "adwaita-dark";
  };

  # Enable polkit
  security.polkit.enable = true;
  
  # Polkit authentication agent
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # Default Hyprland configuration
  environment.etc."xdg/hypr/hyprland.conf" = {
    text = ''
      # ShinigamiNix Default Hyprland Configuration
      
      # Monitor configuration (adjust as needed)
      monitor=,preferred,auto,auto
      
      # Graphics compatibility settings for flickering issues
      env = WLR_NO_HARDWARE_CURSORS,1
      env = WLR_RENDERER_ALLOW_SOFTWARE,1
      env = WLR_DRM_NO_ATOMIC,1
      
      # Execute your favorite apps at launch
      exec-once = waybar
      exec-once = hyprpaper
      exec-once = mako
      exec-once = nm-applet --indicator
      exec-once = blueman-applet
      
      # Source a file (multi-file configs)
      # source = ~/.config/hypr/myColors.conf
      
      # Some default env vars.
      env = XCURSOR_SIZE,24
      env = QT_QPA_PLATFORMTHEME,qt5ct
      
      # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
      input {
          kb_layout = us
          kb_variant =
          kb_model =
          kb_options =
          kb_rules =
      
          follow_mouse = 1
      
          touchpad {
              natural_scroll = no
          }
      
          sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
      }
      
      general {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
      
          gaps_in = 5
          gaps_out = 20
          border_size = 2
          col.active_border = rgba(D4B896ee) rgba(C9A876ee) 45deg
          col.inactive_border = rgba(595959aa)
      
          layout = dwindle
      
          # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
          allow_tearing = false
      }
      
      decoration {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
      
          rounding = 10
      
          blur {
              enabled = true
              size = 3
              passes = 1
          }
      
          drop_shadow = yes
          shadow_range = 4
          shadow_render_power = 3
          col.shadow = rgba(1a1a1aee)
      }
      
      animations {
          enabled = yes
      
          # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more
      
          bezier = myBezier, 0.05, 0.9, 0.1, 1.05
      
          animation = windows, 1, 7, myBezier
          animation = windowsOut, 1, 7, default, popin 80%
          animation = border, 1, 10, default
          animation = borderangle, 1, 8, default
          animation = fade, 1, 7, default
          animation = workspaces, 1, 6, default
      }
      
      dwindle {
          # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
          pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
          preserve_split = yes # you probably want this
      }
      
      master {
          # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
          new_is_master = true
      }
      
      gestures {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
          workspace_swipe = off
      }
      
      misc {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
          force_default_wallpaper = 0 # Set to 0 to disable the anime mascot wallpapers
      }
      
      # Example per-device config
      # See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
      device:epic-mouse-v1 {
          sensitivity = -0.5
      }
      
      # KEYBINDINGS
      # See https://wiki.hyprland.org/Configuring/Keywords/ for more
      $mainMod = SUPER
      
      # Application launchers
      bind = $mainMod, D, exec, wofi --show drun
      bind = $mainMod, SPACE, exec, rofi -show drun
      bind = $mainMod, R, exec, rofi -show run
      
      # Terminal
      bind = $mainMod, Return, exec, kitty
      bind = $mainMod, T, exec, kitty
      
      # Applications
      bind = $mainMod, E, exec, thunar
      bind = $mainMod, B, exec, brave
      bind = $mainMod, C, exec, code
      bind = $mainMod SHIFT, D, exec, discord
      bind = $mainMod, S, exec, steam
      bind = $mainMod, M, exec, prismlauncher
      
      # Window management
      bind = $mainMod, Q, killactive,
      bind = $mainMod SHIFT, Q, exit,
      bind = $mainMod, V, togglefloating,
      bind = $mainMod, F, fullscreen,
      bind = $mainMod, P, pseudo, # dwindle
      bind = $mainMod, J, togglesplit, # dwindle
      
      # Move focus with mainMod + arrow keys
      bind = $mainMod, left, movefocus, l
      bind = $mainMod, right, movefocus, r
      bind = $mainMod, up, movefocus, u
      bind = $mainMod, down, movefocus, d
      
      # Move focus with mainMod + vim keys
      bind = $mainMod, h, movefocus, l
      bind = $mainMod, l, movefocus, r
      bind = $mainMod, k, movefocus, u
      bind = $mainMod, j, movefocus, d
      
      # Switch workspaces with mainMod + [0-9]
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9
      bind = $mainMod, 0, workspace, 10
      
      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      bind = $mainMod SHIFT, 1, movetoworkspace, 1
      bind = $mainMod SHIFT, 2, movetoworkspace, 2
      bind = $mainMod SHIFT, 3, movetoworkspace, 3
      bind = $mainMod SHIFT, 4, movetoworkspace, 4
      bind = $mainMod SHIFT, 5, movetoworkspace, 5
      bind = $mainMod SHIFT, 6, movetoworkspace, 6
      bind = $mainMod SHIFT, 7, movetoworkspace, 7
      bind = $mainMod SHIFT, 8, movetoworkspace, 8
      bind = $mainMod SHIFT, 9, movetoworkspace, 9
      bind = $mainMod SHIFT, 0, movetoworkspace, 10
      
      # Example special workspace (scratchpad)
      bind = $mainMod, grave, togglespecialworkspace, magic
      bind = $mainMod SHIFT, grave, movetoworkspace, special:magic
      
      # Scroll through existing workspaces with mainMod + scroll
      bind = $mainMod, mouse_down, workspace, e+1
      bind = $mainMod, mouse_up, workspace, e-1
      
      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow
      
      # Screenshots
      bind = , Print, exec, grim -g "$(slurp)" - | wl-copy
      bind = SHIFT, Print, exec, grim - | wl-copy
      
      # Media keys
      bind = , XF86AudioRaiseVolume, exec, pamixer -i 5
      bind = , XF86AudioLowerVolume, exec, pamixer -d 5
      bind = , XF86AudioMute, exec, pamixer -t
      bind = , XF86AudioPlay, exec, playerctl play-pause
      bind = , XF86AudioPause, exec, playerctl play-pause
      bind = , XF86AudioNext, exec, playerctl next
      bind = , XF86AudioPrev, exec, playerctl previous
      
      # Brightness keys
      bind = , XF86MonBrightnessDown, exec, brightnessctl set 5%-
      bind = , XF86MonBrightnessUp, exec, brightnessctl set +5%
      
      # Lock screen
      bind = $mainMod, L, exec, hyprlock
    '';
    mode = "0644";
  };
}
