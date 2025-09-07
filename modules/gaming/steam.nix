{ config, lib, pkgs, inputs, ... }:

{
  # Enable Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    
    # Enable Steam Proton
    package = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [
        # Additional packages for Steam
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib
        libkrb5
        keyutils
        # Proton dependencies
        wineWowPackages.waylandFull
        winetricks
        # Controller support
        xboxdrv
      ];
    };
  };

  # GameMode for performance optimization
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
        ioprio = 0;
        inhibit_screensaver = 1;
        softrealtime = "auto";
        reaper_freq = 5;
      };
      
      filter = {
        whitelist = [ "steam" "lutris" "bottles" ];
      };
      
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        amd_performance_level = "high";
      };
      
      cpu = {
        park_cores = "no";
        pin_cores = "no";
      };
    };
  };

  # Gaming-related packages
  environment.systemPackages = with pkgs; [
    # Game launchers and stores
    lutris          # Open gaming platform
    bottles         # Wine prefix manager
    heroic          # Epic Games and GOG launcher
    
    # Wine and compatibility
    wineWowPackages.waylandFull
    winetricks
    dxvk
    
    # Game development
    godot_4
    unity3d
    
    # Emulation
    retroarch
    dolphin-emu
    pcsx2
    rpcs3
    
    # Controller support
    xboxdrv
    antimicrox
    
    # Performance monitoring
    mangohud        # Gaming overlay
    goverlay        # MangoHud configurator
    
    # Recording and streaming
    obs-studio
    
    # Game tools
    steamtinkerlaunch
    protontricks
    
    # Audio for gaming
    teamspeak_client
    discord
    
    # Game-specific tools
    minecraft
    
    # System optimization
    gamemode
    
    # Graphics tools
    vulkan-tools
    vulkan-validation-layers
    mesa-demos
    
    # Input tools
    evtest          # Input device testing
    
    # Game save backup
    ludusavi        # Game save backup tool
  ];

  # Hardware acceleration for gaming
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    
    extraPackages = with pkgs; [
      # Intel graphics
      intel-media-driver
      intel-vaapi-driver
      vaapiIntel
      intel-compute-runtime
      
      # Vulkan
      vulkan-loader
      vulkan-validation-layers
      vulkan-extension-layer
      
      # Mesa
      mesa.drivers
    ];
    
    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-media-driver
      intel-vaapi-driver
      vaapiIntel
      vulkan-loader
      vulkan-validation-layers
    ];
  };

  # Gaming-specific services
  services = {
    # Flatpak for additional gaming applications
    flatpak.enable = true;
    
    # Gamemode daemon
    # (automatically enabled with programs.gamemode.enable)
  };

  # Gaming-specific environment variables
  environment.sessionVariables = {
    # Steam
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.steam/root/compatibilitytools.d";
    
    # Proton
    PROTON_ENABLE_NVAPI = "1";
    PROTON_ENABLE_NGX_UPDATER = "1";
    
    # MangoHud
    MANGOHUD = "1";
    
    # Vulkan
    VK_LAYER_PATH = "$VK_LAYER_PATH:${pkgs.vulkan-validation-layers}/share/vulkan/explicit_layer.d";
    
    # Wine
    WINEPREFIX = "$HOME/.wine";
    
    # GameMode
    GAMEMODE_ENABLED = "1";
  };

  # Gaming-specific kernel parameters and optimizations
  boot.kernel.sysctl = {
    # Memory management for gaming
    "vm.max_map_count" = 2147483642;
    
    # Network optimizations for online gaming
    "net.core.netdev_max_backlog" = 5000;
    "net.core.rmem_default" = 31457280;
    "net.core.rmem_max" = 134217728;
    "net.core.wmem_default" = 31457280;
    "net.core.wmem_max" = 134217728;
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "cake";
  };

  # Firewall rules for gaming
  networking.firewall = {
    allowedTCPPorts = [
      # Steam
      27036 27037
      # Minecraft
      25565
    ];
    
    allowedUDPPorts = [
      # Steam
      27031 27036
      # Gaming general
      3478 4379 4380
    ];
  };

  # User groups for gaming
  users.users.reaper.extraGroups = [
    "gamemode"      # GameMode access
    "input"         # Controller access
    "audio"         # Audio access for games
  ];

  # Gaming-specific udev rules
  services.udev.extraRules = ''
    # Steam Controller
    SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666"
    
    # PlayStation controllers
    SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="05c4", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="09cc", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0666"
    
    # Xbox controllers
    SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02d1", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02dd", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0719", MODE="0666"
    
    # Nintendo controllers
    SUBSYSTEM=="usb", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2009", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2006", MODE="0666"
    
    # Performance scaling for games
    SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="on"
  '';

  # Audio optimizations for gaming
  security.rtkit.enable = true;
  
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    
    # Low latency configuration for gaming
    extraConfig.pipewire."92-low-latency" = {
      context.properties = {
        default.clock.rate = 48000;
        default.clock.quantum = 32;
        default.clock.min-quantum = 32;
        default.clock.max-quantum = 32;
      };
    };
  };

  # Enable 32-bit support for gaming
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;

  # Gaming-specific systemd services
  systemd.services.gamemode-optimization = {
    description = "Gaming performance optimization";
    wantedBy = [ "multi-user.target" ];
    script = ''
      # Set CPU governor to performance when gaming
      echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
      
      # Disable CPU mitigations for performance (gaming only)
      echo 0 | tee /sys/devices/system/cpu/vulnerabilities/*/
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
