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
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    GDK_BACKEND = "wayland,x11";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
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
}
