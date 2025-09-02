{ config, lib, pkgs, ... }:

{
  # Graphics drivers and optimizations for gaming

  # OpenGL/Vulkan support
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    
    # Intel graphics packages
    extraPackages = with pkgs; [
      # Intel media driver (for newer Intel GPUs)
      intel-media-driver
      
      # VAAPI drivers for hardware acceleration
      intel-vaapi-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      
      # Intel compute runtime for OpenCL
      intel-compute-runtime
      
      # Vulkan drivers
      vulkan-loader
      vulkan-validation-layers
      vulkan-extension-layer
      vulkan-tools
      
      # Mesa drivers
      mesa.drivers
      
      # Additional graphics libraries
      libGL
      libGLU
      freeglut
      glfw
      glew
    ];
    
    # 32-bit graphics support for gaming
    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-media-driver
      intel-vaapi-driver
      vaapiIntel
      vulkan-loader
      vulkan-validation-layers
      mesa.drivers
      libGL
      libGLU
      freeglut
      glfw
      glew
    ];
  };

  # Gaming-specific graphics packages
  environment.systemPackages = with pkgs; [
    # Graphics utilities
    glxinfo
    vulkan-tools
    vulkan-validation-layers
    mesa-demos
    
    # Performance monitoring
    nvtop           # GPU monitoring
    radeontop       # AMD GPU monitoring (works with Intel too)
    intel-gpu-tools # Intel GPU utilities
    
    # Graphics debugging
    apitrace        # OpenGL/Vulkan tracing
    renderdoc       # Graphics debugger
    
    # Color management
    argyllcms       # Color calibration
    displaycal      # Display calibration GUI
    
    # HDR support tools
    hdr10plus_tool  # HDR10+ tools
    
    # Video encoding/decoding
    libva-utils     # VAAPI utilities
    vdpauinfo       # VDPAU info
    
    # Gaming overlays and tools
    mangohud        # Performance overlay
    goverlay        # MangoHud configurator
    obs-studio      # Streaming/recording
    
    # Graphics benchmarking
    glmark2         # OpenGL benchmark
    unigine-superposition # 3D benchmark
    
    # Screenshot tools
    flameshot       # Screenshot tool
    grim            # Wayland screenshot
    slurp           # Wayland screen selection
    
    # Image viewers optimized for gaming screenshots
    feh
    imv
    
    # Video players with hardware acceleration
    mpv             # Media player with GPU acceleration
    vlc             # Alternative media player
  ];

  # Graphics-related services
  services = {
    # X11 configuration (for XWayland)
    xserver = {
      enable = false; # We're using Wayland primarily
      videoDrivers = [ "intel" "modesetting" ];
    };
  };

  # Environment variables for graphics optimization
  environment.sessionVariables = {
    # Vulkan
    VK_LAYER_PATH = "${pkgs.vulkan-validation-layers}/share/vulkan/explicit_layer.d";
    VK_ICD_FILENAMES = "${pkgs.mesa.drivers}/share/vulkan/icd.d/intel_icd.x86_64.json";
    
    # VAAPI
    LIBVA_DRIVER_NAME = "iHD"; # Intel media driver
    
    # OpenGL
    MESA_LOADER_DRIVER_OVERRIDE = "iris"; # Intel Iris driver
    
    # Intel graphics optimizations
    INTEL_DEBUG = "norbc"; # Disable render buffer compression for better compatibility
    
    # Gaming-specific
    __GL_SHADER_DISK_CACHE = "1";
    __GL_SHADER_DISK_CACHE_PATH = "$HOME/.cache/mesa_shader_cache";
    
    # Wayland graphics
    GBM_BACKEND = "nvidia-drm"; # For NVIDIA (not applicable here but good to have)
    WLR_NO_HARDWARE_CURSORS = "1"; # Fix cursor issues in some games
    
    # MangoHud configuration
    MANGOHUD_CONFIG = "cpu_temp,gpu_temp,position=top-left,height=500,font_size=32";
  };

  # Kernel modules and parameters for graphics
  boot = {
    # Enable early KMS for better boot experience
    initrd.kernelModules = [ "i915" ];
    
    # Kernel parameters for Intel graphics optimization
    kernelParams = [
      # Intel graphics
      "i915.enable_guc=2"          # Enable GuC firmware loading
      "i915.enable_fbc=1"          # Enable framebuffer compression
      "i915.enable_psr=1"          # Enable panel self refresh
      "i915.fastboot=1"            # Enable fastboot
      "i915.modeset=1"             # Enable kernel mode setting
      
      # Memory management for gaming
      "intel_iommu=on"             # Enable IOMMU
      "iommu=pt"                   # Passthrough mode for better performance
      
      # Performance optimizations
      "mitigations=off"            # Disable CPU mitigations for performance (gaming only)
      "nowatchdog"                 # Disable watchdog for better performance
      "nmi_watchdog=0"             # Disable NMI watchdog
      
      # Graphics-specific
      "video=HDMI-A-1:1920x1080@60" # Set default resolution (adjust as needed)
    ];
  };

  # Graphics-related systemd services
  systemd.services = {
    # GPU frequency scaling optimization
    gpu-performance = {
      description = "GPU Performance Optimization";
      wantedBy = [ "multi-user.target" ];
      after = [ "graphical.target" ];
      script = ''
        # Set Intel GPU to maximum performance
        if [ -d /sys/class/drm/card0/gt_max_freq_mhz ]; then
          echo $(cat /sys/class/drm/card0/gt_boost_freq_mhz) > /sys/class/drm/card0/gt_min_freq_mhz
        fi
        
        # Enable GPU powersave features when not gaming
        echo auto > /sys/bus/pci/devices/0000:00:02.0/power/control 2>/dev/null || true
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "root";
      };
    };
  };

  # udev rules for graphics optimization
  services.udev.extraRules = ''
    # Intel graphics power management
    SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="auto"
    SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{class}=="0x038000", TEST=="power/control", ATTR{power/control}="auto"
    
    # Graphics card access for gaming
    KERNEL=="card*", SUBSYSTEM=="drm", TAG+="seat", TAG+="master-of-seat"
    KERNEL=="renderD*", SUBSYSTEM=="drm", MODE="0666"
    
    # Intel GPU tools access
    SUBSYSTEM=="drm", KERNEL=="card*", GROUP="video", MODE="0664"
    SUBSYSTEM=="drm", KERNEL=="controlD*", GROUP="video", MODE="0664"
    SUBSYSTEM=="drm", KERNEL=="renderD*", GROUP="render", MODE="0664"
  '';

  # Gaming-optimized Mesa configuration
  environment.etc."drirc".text = ''
    <driconf>
      <device>
        <application name="Default">
          <!-- Disable VSync for gaming performance -->
          <option name="vblank_mode" value="0" />
          
          <!-- Enable threading for better performance -->
          <option name="mesa_glthread" value="true" />
          
          <!-- Shader cache optimization -->
          <option name="shader_cache_max_size" value="2GB" />
          
          <!-- Memory management -->
          <option name="allow_higher_compat_version" value="true" />
        </application>
        
        <!-- Steam-specific optimizations -->
        <application name="steam">
          <option name="mesa_glthread" value="true" />
          <option name="vblank_mode" value="0" />
        </application>
        
        <!-- Gaming-specific applications -->
        <application name="wine">
          <option name="mesa_glthread" value="true" />
          <option name="vblank_mode" value="0" />
        </application>
      </device>
    </driconf>
  '';

  # Fonts for gaming (for better text rendering in games)
  fonts.packages = with pkgs; [
    # Gaming fonts
    liberation_ttf  # Windows font alternatives
    corefonts       # Microsoft fonts
    vistafonts      # Vista fonts for gaming
    
    # Monospace fonts for gaming overlays
    source-code-pro
    fira-code
  ];

  # Audio-visual synchronization for gaming
  services.pipewire.extraConfig.pipewire."99-gaming-latency" = {
    "context.properties" = {
      # Low latency for gaming
      "default.clock.rate" = 48000;
      "default.clock.quantum" = 32;
      "default.clock.min-quantum" = 32;
      "default.clock.max-quantum" = 32;
    };
  };
}
