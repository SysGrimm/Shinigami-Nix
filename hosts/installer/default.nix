{ config, pkgs, lib, modulesPath, ... }:

let
  shinigaminixPlymouth = pkgs.callPackage ./../../assets/shinigaminix-plymouth.nix {};
in

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Custom ISO branding and boot configuration
  isoImage = {
    isoName = "ShinigamiNix-installer.iso";
    makeEfiBootable = true;
    makeUsbBootable = true;
    
    # Boot menu branding
    isoBaseName = lib.mkForce "ShinigamiNix";
    volumeID = "SHINIGAMI_NIX";
  };

  # Plymouth boot splash
  boot.plymouth = {
    enable = true;
    themePackages = [ shinigaminixPlymouth ];
    theme = "shinigaminix";
  };

  # Kernel parameters for better boot experience and graphics stability
  boot.kernelParams = [ 
    "quiet" 
    "splash" 
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    # Graphics stability fixes for flickering
    "i915.modeset=1"
    "amdgpu.modeset=1"
    "nouveau.modeset=1"
    "radeon.modeset=1"
    "video=vesafb:off"
    "video=efifb:off"
    "drm.debug=0"
  ];

  # Console settings for boot
  console = {
    font = "ter-128n";
    packages = [ pkgs.terminus_font ];
    earlySetup = true;
  };

  # Enable Hyprland
  programs.hyprland.enable = true;

  # Enable Nix flakes and other experimental features
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Nix configuration for installation
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Enable Wayland compositor essentials
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # Audio support
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable Tailscale
  services.tailscale.enable = true;

  # Hardware support
  hardware.bluetooth.enable = true;
  hardware.opengl.driSupport32Bit = true;

  # Your requested applications
  environment.systemPackages = with pkgs; [
    # Desktop essentials
    kitty              # Modern GPU-accelerated terminal
    waybar             # Status bar for Wayland
    rofi-wayland       # Application launcher
    mako               # Notification daemon
    grim               # Screenshot tool
    slurp              # Screen selection
    wl-clipboard       # Clipboard utilities
    
    # Your applications
    brave
    vscode
    discord
    steam
    prismlauncher
    chiaki-ng
    
    # System tools
    tailscale
    git
    curl
    wget
    neovim
    networkmanagerapplet
    pavucontrol
    brightnessctl
    xfce.thunar
    
    # Additional Hyprland utilities
    wofi               # Alternative launcher (lighter than rofi)
    swww               # Wallpaper daemon for Wayland
    hyprpaper          # Wallpaper utility specifically for Hyprland
    hypridle           # Idle daemon for Hyprland
    hyprlock           # Screen locker for Hyprland
    wlogout            # Logout menu for Wayland
    swaynotificationcenter  # Notification center
    
    # Installation tools
    nixos-install-tools    # NixOS installation utilities
    gparted               # Partition manager with GUI
    parted                # Command-line partitioning
    util-linux            # Disk utilities including fdisk
    rsync                 # File synchronization
    dosfstools            # FAT filesystem utilities
    ntfs3g                # NTFS support
    
    # Network troubleshooting tools
    wget
    curl
    iputils               # ping, traceroute, etc.
    dig
    nmap
    iw                    # Wireless tools
    networkmanager
    
    # Text editors for config editing
    nano
    vim
    
    # Installer utility scripts
    (pkgs.writeScriptBin "fix-filesystems" ''
      #!/bin/bash
      
      echo "## Filesystem Configuration Checker"
      echo "===================================="
      echo ""
      
      echo "Checking mounted filesystems..."
      lsblk
      echo ""
      
      echo "Checking if /mnt is mounted..."
      if ! mountpoint -q /mnt; then
        echo "ERROR: /mnt is not mounted!"
        echo ""
        echo "Available disks:"
        sudo fdisk -l | grep "Disk /dev"
        echo ""
        echo "Please mount your root partition manually:"
        echo "  sudo mount /dev/sdX1 /mnt  # Replace X1 with your root partition"
        echo "  sudo mkdir -p /mnt/boot"
        echo "  sudo mount /dev/sdX2 /mnt/boot  # Replace X2 with your boot partition"
        exit 1
      fi
      echo "OK: /mnt is mounted"
      
      echo ""
      echo "Checking hardware configuration..."
      if [ ! -f /mnt/etc/nixos/hardware-configuration.nix ]; then
        echo "WARNING: hardware-configuration.nix not found. Generating..."
        sudo nixos-generate-config --root /mnt
        if [ $? -eq 0 ]; then
          echo "OK: Hardware configuration generated"
        else
          echo "ERROR: Failed to generate hardware configuration"
          exit 1
        fi
      else
        echo "OK: Hardware configuration exists"
      fi
      
      echo ""
      echo "Checking filesystem configuration..."
      if grep -q "fileSystems" /mnt/etc/nixos/hardware-configuration.nix; then
        echo "OK: Filesystem configuration found"
        echo ""
        echo "Current filesystem configuration:"
        grep -A 10 "fileSystems" /mnt/etc/nixos/hardware-configuration.nix
      else
        echo "ERROR: No filesystem configuration found!"
        echo "Re-generating hardware configuration..."
        sudo nixos-generate-config --root /mnt --force
        if grep -q "fileSystems" /mnt/etc/nixos/hardware-configuration.nix; then
          echo "FIXED: Filesystem configuration generated"
        else
          echo "ERROR: Still no filesystem configuration. Manual intervention required."
          echo ""
          echo "Please check:"
          echo "1. Are your partitions properly mounted to /mnt?"
          echo "2. Is the disk partitioned correctly?"
          echo "3. Try running: sudo nixos-generate-config --root /mnt --force"
          exit 1
        fi
      fi
      
      echo ""
      echo "SUCCESS: Filesystem configuration looks good!"
      echo "You can now proceed with installation using: quick-install"
    '')
    
    (pkgs.writeScriptBin "quick-install" ''
      #!/bin/bash
      
      echo "## ShinigamiNix Installation Guide"
      echo "=================================="
      echo ""
      echo "WARNING: This will install ShinigamiNix from the GitHub repository."
      echo "Make sure your disk is partitioned and mounted to /mnt first!"
      echo ""
      echo "Quick checklist:"
      echo "1. Disk partitioned (EFI + root + swap)"
      echo "2. Partitions formatted"
      echo "3. Root mounted to /mnt"
      echo "4. Boot partition mounted to /mnt/boot"
      echo "5. Swap activated"
      echo ""
      echo "If you need help with partitioning, type 'nixos-help' first."
      echo "Press Enter to continue with installation or Ctrl+C to abort."
      read
      
      echo ""
      echo "Step 1: Checking filesystem configuration..."
      if ! fix-filesystems; then
        echo "ERROR: Filesystem check failed. Please fix the issues above first."
        exit 1
      fi
      
      echo ""
      echo "Step 2: Checking network connectivity..."
      if ! ping -c 3 cache.nixos.org >/dev/null 2>&1; then
        echo "WARNING: Network issues detected!"
        echo "Would you like to run network diagnostics? (y/N)"
        read net_choice
        if [[ "$net_choice" =~ ^[Yy]$ ]]; then
          fix-network
        else
          echo "WARNING: Proceeding without network check - installation may fail"
        fi
      else
        echo "OK: Network connection verified"
      fi
      
      echo ""
      echo "Step 3: Installing ShinigamiNix..."
      echo "This will download and install the complete ShinigamiNix system."
      echo "The installation may take 15-30 minutes depending on your internet speed."
      echo ""
      echo "Press Enter to start installation or Ctrl+C to abort."
      read
      
      echo "Starting installation..."
      cd /mnt/etc/nixos
      sudo NIX_CONFIG="experimental-features = nix-command flakes" nixos-install --flake github:SysGrimm/ShinigamiNix#installer
      
      if [ $? -eq 0 ]; then
        echo ""
        echo "SUCCESS: ShinigamiNix installation completed successfully!"
        echo ""
        echo "Next steps:"
        echo "1. Set a root password: sudo nixos-enter --root /mnt -c 'passwd'"
        echo "2. Create a user account: sudo nixos-enter --root /mnt -c 'useradd -m -G wheel username'"
        echo "3. Set user password: sudo nixos-enter --root /mnt -c 'passwd username'"
        echo "4. Reboot and remove installation media"
        echo ""
        echo "Type 'reboot' when ready to restart into ShinigamiNix!"
      else
        echo ""
        echo "ERROR: Installation failed!"
        echo ""
        echo "Troubleshooting tips:"
        echo "1. Check filesystem configuration: fix-filesystems"
        echo "2. Check network: fix-network"
        echo "3. Try manual installation:"
        echo "   sudo NIX_CONFIG='experimental-features = nix-command flakes' nixos-install --flake github:SysGrimm/ShinigamiNix#installer"
        echo ""
        echo "Check the error messages above for specific issues."
      fi
    '')
    
    (pkgs.writeScriptBin "fix-network" ''
      #!/bin/bash
      
      echo "## Network Troubleshooting"
      echo "========================="
      echo ""
      
      echo "Checking network interfaces..."
      ip link show
      echo ""
      
      echo "Checking IP addresses..."
      ip addr show
      echo ""
      
      echo "Testing connectivity..."
      echo "Ping Google DNS (8.8.8.8):"
      if ping -c 3 8.8.8.8 >/dev/null 2>&1; then
        echo "OK: Internet connectivity working"
      else
        echo "ERROR: No internet connectivity"
      fi
      
      echo ""
      echo "Ping NixOS cache:"
      if ping -c 3 cache.nixos.org >/dev/null 2>&1; then
        echo "OK: NixOS cache reachable"
      else
        echo "ERROR: Cannot reach NixOS cache"
        echo "This may cause installation issues."
      fi
      
      echo ""
      echo "DNS Resolution test:"
      if nslookup cache.nixos.org >/dev/null 2>&1; then
        echo "OK: DNS resolution working"
      else
        echo "ERROR: DNS resolution failed"
        echo "Setting fallback DNS..."
        echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
        echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf
      fi
      
      echo ""
      echo "Manual network setup options:"
      echo "1. WiFi setup: nmtui"
      echo "2. Ethernet: check cable connection"
      echo "3. Manual IP: ip addr add 192.168.1.100/24 dev eth0"
      echo "4. Manual route: ip route add default via 192.168.1.1"
    '')
    
    (pkgs.writeScriptBin "nixos-help" ''
      #!/bin/bash
      
      echo "## ShinigamiNix Installation Guide"
      echo "=================================="
      echo ""
      echo "STEP-BY-STEP INSTALLATION:"
      echo ""
      echo "1. Partition your disk:"
      echo "   - Open GParted: gparted"
      echo "   - Create EFI partition (512MB, fat32)"
      echo "   - Create root partition (rest of disk, ext4)"
      echo "   - Optionally create swap partition"
      echo ""
      echo "2. Mount partitions:"
      echo "   - mount /dev/sdX2 /mnt"
      echo "   - mkdir -p /mnt/boot"
      echo "   - mount /dev/sdX1 /mnt/boot"
      echo ""
      echo "3. Generate hardware config:"
      echo "   - nixos-generate-config --root /mnt"
      echo ""
      echo "4. Install ShinigamiNix:"
      echo "   - Use: quick-install (recommended)"
      echo "   - Or manual: install-nixos"
      echo ""
      echo "5. Reboot:"
      echo "   - reboot"
      echo ""
      echo "NETWORK TROUBLESHOOTING:"
      echo "   - Check connection: ping cache.nixos.org"
      echo "   - Fix network: fix-network"
      echo "   - Check WiFi: nmtui (NetworkManager TUI)"
      echo "   - Manual DNS: echo 'nameserver 8.8.8.8' | sudo tee /etc/resolv.conf"
      echo ""
      echo "FILESYSTEM TROUBLESHOOTING:"
      echo "   - Check/fix filesystems: fix-filesystems"
      echo "   - Check mounts: lsblk or mount | grep /mnt"
      echo "   - Re-generate config: sudo nixos-generate-config --root /mnt --force"
      echo ""
      echo "TIPS:"
      echo "   - Use 'lsblk' to see your disks"
      echo "   - Use 'quick-install' for guided installation"
      echo "   - Use 'gparted' for easy GUI partitioning"
      echo "   - Use 'fix-network' if you have connectivity issues"
      echo ""
    '')
  ];

  # Create desktop entries for installation
  environment.etc = {
    "skel/.config/autostart/welcome.desktop" = {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Welcome to ShinigamiNix
        Comment=Installation and setup guide
        Exec=kitty --title ShinigamiNix-Installer -e bash -c 'echo "Welcome to ShinigamiNix Live Environment!"; echo ""; echo "To install NixOS:"; echo "1. Run: sudo nixos-install"; echo "2. Or for GUI partitioning: gparted"; echo "3. Need help? Type: nixos-help"; echo ""; echo "Press Enter to continue..."; read'
        Icon=distributor-logo-nixos
        Terminal=false
        Categories=System;
        X-GNOME-Autostart-enabled=true
      '';
      mode = "0644";
    };
    
    "skel/Desktop/Install NixOS.desktop" = {
      text = ''
        [Desktop Entry]
        Version=1.0
        Type=Application
        Name=Install NixOS
        Comment=Guided NixOS Installation
        Exec=kitty --title NixOS-Installer -e bash -c 'quick-install; echo "Press Enter to close..."; read'
        Icon=system-software-install
        Terminal=false
        Categories=System;
      '';
      mode = "0755";
    };
    
    "skel/Desktop/Partition Disks.desktop" = {
      text = ''
        [Desktop Entry]
        Version=1.0
        Type=Application
        Name=Partition Disks
        Comment=Partition disks with GParted
        Exec=sudo gparted
        Icon=gparted
        Terminal=false
        Categories=System;
      '';
      mode = "0755";
    };
    
    "skel/Desktop/Terminal.desktop" = {
      text = ''
        [Desktop Entry]
        Version=1.0
        Type=Application
        Name=Terminal
        Comment=Open Terminal (type 'nixos-help' for installation guide)
        Exec=kitty
        Icon=utilities-terminal
        Terminal=false
        Categories=System;TerminalEmulator;
      '';
      mode = "0755";
    };
  };

  # Live session user (inherits from minimal CD)
  # Enable sudo without password for live session
  security.sudo.wheelNeedsPassword = false;
  users.users.nixos.extraGroups = [ "wheel" "video" "audio" ];  # Enable helpful services for installation
  services.udisks2.enable = true;  # Auto-mounting
  services.gvfs.enable = true;     # Virtual filesystem
  
  # Network services
  networking.networkmanager.enable = true;
  networking.wireless.enable = false;  # Disable wpa_supplicant (conflicts with NetworkManager)
  
  # Add helpful aliases and scripts
  environment.interactiveShellInit = ''
    alias ll='ls -la'
    alias la='ls -la'
          install-nixos = "sudo NIX_CONFIG='experimental-features = nix-command flakes' nixos-install --flake github:SysGrimm/ShinigamiNix#installer";
    alias partition='sudo gparted'
    alias check-network='ping -c 3 cache.nixos.org'
    
    # Network troubleshooting function
    fix-network() {
      echo "Network Troubleshooting:"
      echo "========================"
      echo ""
      echo "1. Checking network connectivity..."
      if ping -c 3 8.8.8.8 >/dev/null 2>&1; then
        echo "✅ Internet connection working"
      else
        echo "❌ No internet connection"
        echo "Try: sudo systemctl restart NetworkManager"
        return 1
      fi
      
      echo ""
      echo "2. Checking DNS resolution..."
      if ping -c 3 cache.nixos.org >/dev/null 2>&1; then
        echo "✅ DNS working - cache.nixos.org reachable"
      else
        echo "❌ DNS issues - trying to fix..."
        echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
        echo "nameserver 1.1.1.1" | sudo tee -a /etc/resolv.conf
        echo "Retesting..."
        if ping -c 3 cache.nixos.org >/dev/null 2>&1; then
          echo "✅ DNS fixed!"
        else
          echo "❌ Still having DNS issues"
          echo "Try connecting to WiFi or ethernet"
          return 1
        fi
      fi
      
      echo ""
      echo "3. Testing cache.nixos.org access..."
      if curl -s --head https://cache.nixos.org >/dev/null; then
        echo "✅ Cache server accessible"
      else
        echo "⚠️  Cache server issues - installation may be slow"
        echo "You can still proceed, but packages will build from source"
      fi
      
      echo ""
      echo "Network diagnostics complete!"
    }
    
    # Fix filesystem configuration issues
    fix-filesystems() {
      echo "🔧 Filesystem Configuration Checker"
      echo "===================================="
      echo ""
      
      echo "Checking mounted filesystems..."
      lsblk
      echo ""
      
      echo "Checking if /mnt is mounted..."
      if ! mountpoint -q /mnt; then
        echo "❌ Error: /mnt is not mounted!"
        echo ""
        echo "Available disks:"
        sudo fdisk -l | grep "Disk /dev"
        echo ""
        echo "Please mount your root partition manually:"
        echo "  sudo mount /dev/sdX1 /mnt  # Replace X1 with your root partition"
        echo "  sudo mkdir -p /mnt/boot"
        echo "  sudo mount /dev/sdX2 /mnt/boot  # Replace X2 with your boot partition"
        return 1
      fi
      echo "✅ /mnt is mounted"
      
      echo ""
      echo "Checking hardware configuration..."
      if [ ! -f /mnt/etc/nixos/hardware-configuration.nix ]; then
        echo "⚠️  hardware-configuration.nix not found. Generating..."
        sudo nixos-generate-config --root /mnt
        if [ $? -eq 0 ]; then
          echo "✅ Hardware configuration generated"
        else
          echo "❌ Failed to generate hardware configuration"
          return 1
        fi
      else
        echo "✅ Hardware configuration exists"
      fi
      
      echo ""
      echo "Checking filesystem configuration..."
      if grep -q "fileSystems" /mnt/etc/nixos/hardware-configuration.nix; then
        echo "✅ Filesystem configuration found"
        echo ""
        echo "Current filesystem configuration:"
        grep -A 10 "fileSystems" /mnt/etc/nixos/hardware-configuration.nix
      else
        echo "❌ No filesystem configuration found!"
        echo "Re-generating hardware configuration..."
        sudo nixos-generate-config --root /mnt --force
        if grep -q "fileSystems" /mnt/etc/nixos/hardware-configuration.nix; then
          echo "✅ Fixed! Filesystem configuration generated"
        else
          echo "❌ Still no filesystem configuration. Manual intervention required."
          echo ""
          echo "Please check:"
          echo "1. Are your partitions properly mounted to /mnt?"
          echo "2. Is the disk partitioned correctly?"
          echo "3. Try running: sudo nixos-generate-config --root /mnt --force"
          return 1
        fi
      fi
      
      echo ""
      echo "🎉 Filesystem configuration looks good!"
      echo "You can now proceed with installation."
    }
    
    # Quick installation script
    quick-install() {
      echo "🚀 ShinigamiNix Installation Guide"
      echo "=================================="
      echo ""
      echo "⚠️  This will install ShinigamiNix from the GitHub repository."
      echo "Make sure your disk is partitioned and mounted to /mnt first!"
      echo ""
      echo "📋 Quick checklist:"
      echo "1. ✓ Disk partitioned (EFI + root + swap)"
      echo "2. ✓ Partitions formatted"
      echo "3. ✓ Root mounted to /mnt"
      echo "4. ✓ Boot partition mounted to /mnt/boot"
      echo "5. ✓ Swap activated"
      echo ""
      echo "If you need help with partitioning, type 'nixos-help' first."
      echo "Press Enter to continue with installation or Ctrl+C to abort."
      read
      
      echo ""
      echo "Step 1: Checking filesystem configuration..."
      if ! fix-filesystems; then
        echo "❌ Filesystem check failed. Please fix the issues above first."
        return 1
      fi
      
      echo ""
      echo "Step 2: Checking network connectivity..."
      if ! ping -c 3 cache.nixos.org >/dev/null 2>&1; then
        echo "⚠️  Network issues detected!"
        echo "Would you like to run network diagnostics? (y/N)"
        read net_choice
        if [[ "$net_choice" =~ ^[Yy]$ ]]; then
          fix-network
        else
          echo "⚠️  Proceeding without network check - installation may fail"
        fi
      else
        echo "✅ Network connection verified"
      fi
      
      echo ""
      echo "Step 3: Installing ShinigamiNix..."
      echo "This will download and install the complete ShinigamiNix system."
      echo "The installation may take 15-30 minutes depending on your internet speed."
      echo ""
      echo "Press Enter to start installation or Ctrl+C to abort."
      read
      
      echo "🔄 Starting installation..."
      cd /mnt/etc/nixos
      sudo NIX_CONFIG="experimental-features = nix-command flakes" nixos-install --flake github:SysGrimm/ShinigamiNix#installer
      
      if [ $? -eq 0 ]; then
        echo ""
        echo "🎉 ShinigamiNix installation completed successfully!"
        echo ""
        echo "Next steps:"
        echo "1. Set a root password: sudo nixos-enter --root /mnt -c 'passwd'"
        echo "2. Create a user account: sudo nixos-enter --root /mnt -c 'useradd -m -G wheel username'"
        echo "3. Set user password: sudo nixos-enter --root /mnt -c 'passwd username'"
        echo "4. Reboot and remove installation media"
        echo ""
        echo "Type 'reboot' when ready to restart into ShinigamiNix!"
      else
        echo ""
        echo "❌ Installation failed!"
        echo ""
        echo "🔧 Troubleshooting tips:"
        echo "1. Check filesystem configuration: fix-filesystems"
        echo "2. Check network: fix-network"
        echo "3. Try manual installation:"
        echo "   sudo NIX_CONFIG='experimental-features = nix-command flakes' nixos-install --flake github:SysGrimm/ShinigamiNix#installer"
        echo ""
        echo "Check the error messages above for specific issues."
      fi
    }
    
    # Show installation help
    nixos-help() {
      echo "ShinigamiNix Installation Guide:"
      echo "================================"
      echo ""
      echo "🚀 QUICK START: Type 'quick-install' for guided installation"
      echo ""
      echo "📋 MANUAL INSTALLATION STEPS:"
      echo ""
      echo "1. Partition your disk:"
      echo "   - GUI: Run 'gparted' or click 'Partition Disks' on desktop"
      echo "   - CLI: Use 'fdisk /dev/sdX' or 'parted /dev/sdX'"
      echo "   - Create: EFI partition (512MB, FAT32) + Root partition (rest, ext4)"
      echo ""
      echo "2. Format partitions:"
      echo "   - EFI: mkfs.fat -F 32 /dev/sdX1"
      echo "   - Root: mkfs.ext4 /dev/sdX2"
      echo ""
      echo "3. Mount partitions:"
      echo "   - mount /dev/sdX2 /mnt"
      echo "   - mkdir -p /mnt/boot"
      echo "   - mount /dev/sdX1 /mnt/boot"
      echo ""
      echo "4. ⚠️  IMPORTANT: Generate config FIRST:"
      echo "   - nixos-generate-config --root /mnt"
      echo "   - This creates /mnt/etc/nixos/configuration.nix"
      echo ""
      echo "5. Edit config (optional):"
      echo "   - nano /mnt/etc/nixos/configuration.nix"
      echo ""
      echo "6. Install:"
      echo "   - NIX_CONFIG='experimental-features = nix-command flakes' sudo nixos-install"
      echo "   - Or use alias: install-nixos"
      echo ""
      echo "7. Reboot:"
      echo "   - reboot"
      echo ""
      echo "🌐 NETWORK TROUBLESHOOTING:"
      echo "   - Check connection: ping cache.nixos.org"
      echo "   - Fix network: fix-network"
      echo "   - Check WiFi: nmtui (NetworkManager TUI)"
      echo "   - Manual DNS: echo 'nameserver 8.8.8.8' | sudo tee /etc/resolv.conf"
      echo ""
      echo "� FILESYSTEM TROUBLESHOOTING:"
      echo "   - Check/fix filesystems: fix-filesystems"
      echo "   - Check mounts: lsblk or mount | grep /mnt"
      echo "   - Re-generate config: sudo nixos-generate-config --root /mnt --force"
      echo ""
      echo "�💡 TIPS:"
      echo "   - Use 'lsblk' to see your disks"
      echo "   - Use 'quick-install' for guided installation"
      echo "   - Use 'gparted' for easy GUI partitioning"
      echo "   - Use 'fix-network' if you have connectivity issues"
      echo ""
    }
  '';
}
