{ config, lib, pkgs, ... }:

{
  # Framework 13 specific optimizations for 2025 model

  # Hardware acceleration and graphics
  hardware = {
    # OpenGL/Graphics
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        libvdpau-va-gl
        intel-compute-runtime
        vaapiIntel
        vaapiVdpau
      ];
    };

    # CPU microcode
    cpu.intel.updateMicrocode = true;

    # Enable firmware with redistributable firmware
    enableRedistributableFirmware = true;
    enableAllFirmware = true;

    # Framework specific hardware
    framework.amd-7040.preventWakeOnAC = true;
  };

  # Power management optimizations for Framework 13
  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "powersave";
  };

  # TLP for better battery management
  services.tlp = {
    enable = true;
    settings = {
      # CPU
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 50;

      # Platform
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      # Processor
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_HWP_DYN_BOOST_ON_AC = 1;
      CPU_HWP_DYN_BOOST_ON_BAT = 0;

      # Kernel laptop mode
      NMI_WATCHDOG = 0;

      # Power saving for Intel AC97 audio
      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;

      # PCI Express Active State Power Management
      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";

      # Graphics
      INTEL_GPU_MIN_FREQ_ON_AC = 100;
      INTEL_GPU_MIN_FREQ_ON_BAT = 100;
      INTEL_GPU_MAX_FREQ_ON_AC = 1200;
      INTEL_GPU_MAX_FREQ_ON_BAT = 800;
      INTEL_GPU_BOOST_FREQ_ON_AC = 1200;
      INTEL_GPU_BOOST_FREQ_ON_BAT = 800;

      # WiFi power saving
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";

      # USB
      USB_AUTOSUSPEND = 1;
      USB_EXCLUDE_PHONE = 1;

      # Battery
      START_CHARGE_THRESH_BAT0 = 40;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # Disable power-profiles-daemon when TLP is enabled
  services.power-profiles-daemon.enable = lib.mkForce false;

  # Framework 13 specific kernel modules
  boot = {
    initrd = {
      availableKernelModules = [ 
        "nvme" 
        "xhci_pci" 
        "thunderbolt" 
        "usb_storage" 
        "sd_mod" 
        "rtsx_pci_sdmmc"
      ];
      kernelModules = [ ];
    };
    
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];

    # Blacklist problematic modules
    blacklistedKernelModules = [ ];

    # Framework 13 specific kernel parameters
    kernelParams = [
      # Intel graphics optimizations
      "i915.enable_guc=2"
      "i915.enable_fbc=1"
      "i915.enable_psr=1"
      "i915.fastboot=1"
      
      # Power management
      "intel_pstate=active"
      "intel_iommu=on"
      
      # Security
      "mitigations=auto"
      
      # Performance
      "nowatchdog"
      "kernel.nmi_watchdog=0"
    ];
  };

  # Framework expansion card support
  services.udev.extraRules = ''
    # Framework expansion cards
    SUBSYSTEM=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0012", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0013", MODE="0666"
    
    # Framework HDMI expansion card
    SUBSYSTEM=="drm", KERNEL=="card[0-9]*", ATTRS{vendor}=="0x32ac", TAG+="seat", TAG+="master-of-seat"
  '';

  # Fingerprint reader support (if available on 2025 model)
  services.fprintd.enable = true;
  
  # Framework specific services
  services.fwupd = {
    enable = true;
    extraRemotes = [ "lvfs-testing" ];
  };

  # Thermal management
  services.thermald.enable = true;

  # Framework laptop mode optimizations
  boot.kernel.sysctl = {
    # VM optimizations
    "vm.dirty_writeback_centisecs" = 6000;
    "vm.laptop_mode" = 5;
    "vm.swappiness" = 1;
    
    # Network optimizations
    "net.core.rmem_default" = 31457280;
    "net.core.rmem_max" = 134217728;
    "net.core.wmem_default" = 31457280;
    "net.core.wmem_max" = 134217728;
    "net.core.netdev_max_backlog" = 5000;
    "net.ipv4.tcp_window_scaling" = 1;
  };

  # Additional hardware support
  hardware.sensor.iio.enable = true; # Ambient light sensor
  
  # Enable TRIM for SSD
  services.fstrim.enable = true;

  # Zram for better memory management
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };
}
