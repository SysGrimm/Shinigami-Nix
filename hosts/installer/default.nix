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
    
    # Text editors for config editing
    nano
    vim
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
        Exec=kitty --title NixOS-Installer -e bash -c 'source /etc/bashrc; quick-install; echo "Press Enter to close..."; read'
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
  users.users.nixos.extraGroups = [ "wheel" "video" "audio" ];

  # Enable helpful services for installation
  services.udisks2.enable = true;  # Auto-mounting
  services.gvfs.enable = true;     # Virtual filesystem
  
  # Add helpful aliases and scripts
  environment.interactiveShellInit = ''
    alias ll='ls -la'
    alias la='ls -la'
    alias install-nixos='sudo nixos-install'
    alias partition='sudo gparted'
    
    # Quick installation script
    quick-install() {
      echo "ShinigamiNix Quick Installation:"
      echo "================================"
      echo ""
      echo "⚠️  WARNING: This will guide you through installation step by step."
      echo "Make sure you have partitioned and mounted your disk first!"
      echo ""
      echo "Have you already:"
      echo "1. Partitioned your disk (using gparted or fdisk)?"
      echo "2. Formatted your partitions?"
      echo "3. Mounted them to /mnt?"
      echo ""
      echo "If YES, press Enter to continue. If NO, type 'nixos-help' first."
      read
      
      echo "Step 1: Checking if /mnt is mounted..."
      if ! mountpoint -q /mnt; then
        echo "❌ Error: /mnt is not mounted!"
        echo "Please mount your root partition first: mount /dev/sdX2 /mnt"
        return 1
      fi
      echo "✅ /mnt is mounted"
      
      echo ""
      echo "Step 2: Generating NixOS configuration..."
      sudo nixos-generate-config --root /mnt
      if [ $? -eq 0 ]; then
        echo "✅ Configuration generated successfully"
      else
        echo "❌ Failed to generate configuration"
        return 1
      fi
      
      echo ""
      echo "Step 3: Configuration file created at /mnt/etc/nixos/configuration.nix"
      echo "Would you like to edit it now? (y/N)"
      read edit_choice
      if [[ "$edit_choice" =~ ^[Yy]$ ]]; then
        sudo nano /mnt/etc/nixos/configuration.nix
      fi
      
      echo ""
      echo "Step 4: Starting NixOS installation..."
      echo "This may take a while. Press Enter to continue."
      read
      sudo nixos-install
      
      if [ $? -eq 0 ]; then
        echo ""
        echo "🎉 Installation completed successfully!"
        echo "You can now reboot and remove the installation media."
        echo "Type 'reboot' when ready."
      else
        echo "❌ Installation failed. Check the error messages above."
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
      echo "   - nixos-install"
      echo ""
      echo "7. Reboot:"
      echo "   - reboot"
      echo ""
      echo "💡 TIPS:"
      echo "   - Use 'lsblk' to see your disks"
      echo "   - Use 'quick-install' for guided installation"
      echo "   - Use 'gparted' for easy GUI partitioning"
      echo ""
    }
  '';
}
