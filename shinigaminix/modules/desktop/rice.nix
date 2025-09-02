{ config, lib, pkgs, inputs, ... }:

{
  # Stylix for system-wide theming
  stylix = {
    enable = true;
    
    # Base16 color scheme - Tokyo Night theme
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
    
    # Wallpaper
    image = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/dharmx/walls/main/anime/tokyo_night.png";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # You'll need to update this
    };
    
    # Cursor theme
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };
    
    # Fonts
    fonts = {
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      
      monospace = {
        package = pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; };
        name = "FiraCode Nerd Font Mono";
      };
      
      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
      
      sizes = {
        applications = 11;
        terminal = 12;
        desktop = 10;
        popups = 10;
      };
    };
  };

  # GTK theme
  environment.systemPackages = with pkgs; [
    # Icon themes
    papirus-icon-theme
    tela-icon-theme
    
    # GTK themes
    adwaita-icon-theme
    gnome.adwaita-icon-theme
    
    # Cursor themes
    bibata-cursors
    
    # Theme tools
    lxappearance
    
    # Wallpaper tools
    nitrogen
    feh
    
    # Additional aesthetic packages
    neofetch
    cmatrix
    pipes
    
    # Color tools
    pywal
  ];

  # Console configuration
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # Services for theming
  services = {
    # Enable location services for automatic light/dark theme
    geoclue2 = {
      enable = true;
      enableDemoAgent = lib.mkForce true;
      geoProviders = [ "mozilla" "nominatim" ];
    };
  };

  # Additional programs for rice
  programs = {
    # Enable fish shell with starship prompt (optional alternative to zsh)
    fish.enable = true;
  };

  # Environment variables for theming
  environment.sessionVariables = {
    # GTK theme
    GTK_THEME = "Adwaita:dark";
    
    # Qt theme
    QT_STYLE_OVERRIDE = "adwaita-dark";
    
    # Cursor theme
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
  };

  # System-wide theming configuration
  environment.etc = {
    # GTK 3 configuration
    "gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-theme-name = Adwaita-dark
      gtk-icon-theme-name = Papirus-Dark
      gtk-cursor-theme-name = Bibata-Modern-Classic
      gtk-cursor-theme-size = 24
      gtk-font-name = DejaVu Sans 11
      gtk-application-prefer-dark-theme = true
      gtk-enable-animations = true
      gtk-primary-button-warps-slider = false
      gtk-toolbar-style = 3
      gtk-menu-images = true
      gtk-button-images = true
    '';
    
    # GTK 4 configuration
    "gtk-4.0/settings.ini".text = ''
      [Settings]
      gtk-theme-name = Adwaita-dark
      gtk-icon-theme-name = Papirus-Dark
      gtk-cursor-theme-name = Bibata-Modern-Classic
      gtk-cursor-theme-size = 24
      gtk-font-name = DejaVu Sans 11
      gtk-application-prefer-dark-theme = true
    '';
  };
}
