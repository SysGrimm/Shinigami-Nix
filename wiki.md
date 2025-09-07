# ShinigamiNix Wiki

## Table of Contents
1. [Project Overview](#project-overview)
2. [System Architecture](#system-architecture)
3. [Installation System](#installation-system)
4. [Configuration Structure](#configuration-structure)
5. [Build System](#build-system)
6. [Hardware Support](#hardware-support)
7. [Desktop Environment](#desktop-environment)
8. [Development Environment](#development-environment)
9. [Gaming Configuration](#gaming-configuration)
10. [Installation Guide](#installation-guide)
11. [Troubleshooting](#troubleshooting)
12. [Development & Contributing](#development--contributing)

---

## Project Overview

ShinigamiNix is a comprehensive NixOS distribution featuring:
- **Custom Installation ISO** with Hyprland desktop environment
- **Hardware-agnostic** support (optimized for Framework 13)
- **Gaming-focused** with Steam, graphics optimizations, and controller support
- **Development-ready** with modern editors, language support, and tools
- **Automated builds** via GitHub Actions
- **Custom branding** with ShinigamiNix Plymouth theme

### Key Features
- ✅ **Live Environment**: Fully functional Hyprland desktop with installation tools
- ✅ **One-Click Installation**: Guided installation scripts with error checking
- ✅ **Gaming Ready**: Steam, Proton, graphics drivers, and gaming utilities
- ✅ **Development Tools**: VSCode, Brave browser, terminal tools, and language support
- ✅ **Network Tools**: Tailscale VPN, NetworkManager, and troubleshooting utilities
- ✅ **Hardware Support**: Intel/AMD/NVIDIA graphics, Framework 13 optimizations
- ✅ **Custom Theming**: Golden ShinigamiNix branding and boot splash

### Repository Information
- **GitHub**: https://github.com/SysGrimm/ShinigamiNix
- **Primary Branch**: `main`
- **Automatic Builds**: GitHub Actions generates ISOs on every commit
- **License**: Open source (specific license in repository)

---

## System Architecture

### Core Components
```
ShinigamiNix System Stack
┌─────────────────────────────────────┐
│            Applications             │ <- Steam, VSCode, Brave, Discord
├─────────────────────────────────────┤
│          Desktop Environment       │ <- Hyprland, Waybar, rofi/wofi
├─────────────────────────────────────┤
│           Window System             │ <- Wayland with hardware acceleration
├─────────────────────────────────────┤
│            NixOS Core               │ <- nixos-unstable base system
├─────────────────────────────────────┤
│            Hardware Layer           │ <- Framework 13, Intel/AMD/NVIDIA
└─────────────────────────────────────┘
```

### Package Management
- **Base**: NixOS with flakes enabled
- **Channel**: nixos-unstable for latest packages
- **Package Manager**: Nix with experimental features enabled
- **Configuration**: Declarative system configuration
- **Reproducibility**: Flake.lock ensures consistent builds

### Graphics Stack
- **Wayland**: Primary display protocol
- **Hardware Acceleration**: Intel/AMD/NVIDIA support
- **Graphics Drivers**: Mesa, Intel, AMDGPU, NVIDIA proprietary
- **Vulkan**: Full Vulkan support for gaming
- **Video Acceleration**: VA-API and VDPAU support

---

## Installation System

### ISO Image Features
The ShinigamiNix installer ISO provides a complete live environment with:

#### Pre-installed Applications
- **Hyprland**: Tiling window manager
- **Kitty**: GPU-accelerated terminal emulator
- **Steam**: Gaming platform with Proton support
- **VSCode**: Integrated development environment
- **Brave Browser**: Privacy-focused web browser
- **Discord**: Communication platform
- **Prism Launcher**: Minecraft launcher
- **chiaki-ng**: PlayStation Remote Play client
- **Tailscale**: VPN and networking tool

#### Installation Tools
- **GParted**: Graphical partition manager
- **Partition tools**: fdisk, parted, util-linux
- **Filesystem support**: ext4, NTFS, FAT32, etc.
- **Network tools**: NetworkManager, ping, dig, nmap
- **Troubleshooting utilities**: Custom diagnostic scripts

#### Installation Scripts
The ISO includes several helper scripts for installation:

##### `nixos-help`
Displays comprehensive installation guide with step-by-step instructions:
```bash
nixos-help
```

##### `fix-filesystems`
Diagnoses and fixes filesystem configuration issues:
```bash
fix-filesystems
```
- Checks if `/mnt` is properly mounted
- Verifies hardware-configuration.nix exists
- Validates filesystem configuration
- Automatically regenerates configuration if needed

##### `quick-install`
Guided installation process with automatic error checking:
```bash
quick-install
```
- Runs filesystem checks
- Verifies network connectivity
- Downloads and installs ShinigamiNix system
- Provides post-installation instructions

##### `fix-network`
Network troubleshooting and diagnostics:
```bash
fix-network
```
- Tests internet connectivity
- Checks DNS resolution
- Displays network configuration
- Provides manual setup options

##### `install-nixos`
Direct installation command for advanced users:
```bash
install-nixos
```
Equivalent to:
```bash
sudo NIX_CONFIG='experimental-features = nix-command flakes' nixos-install --flake github:SysGrimm/ShinigamiNix#installer
```

### Boot Configuration
- **Custom Plymouth Theme**: ShinigamiNix logo with golden progress bar
- **EFI Support**: UEFI boot with Secure Boot compatibility
- **USB Bootable**: Works on any USB drive
- **Legacy BIOS**: Backwards compatibility for older systems

---

## Configuration Structure

### Repository Layout
```
ShinigamiNix/
├── flake.nix                     # Main flake configuration
├── flake.lock                    # Dependency lock file
├── nixpkgs-config.nix           # Nixpkgs configuration
├── wiki.md                      # This documentation
├── LICENSE                      # Project license
│
├── .github/
│   └── workflows/
│       └── build-iso.yml        # GitHub Actions CI/CD
│
├── assets/
│   ├── plymouth/                # Plymouth theme files
│   │   ├── shinigaminix.plymouth
│   │   ├── shinigaminix.script
│   │   └── logo.png            # ShinigamiNix logo
│   └── shinigaminix-plymouth.nix # Plymouth package definition
│
├── hosts/
│   ├── aetherbook/              # Framework 13 configuration
│   │   ├── default.nix          # Host-specific settings
│   │   └── hardware-configuration.nix # Hardware configuration
│   └── installer/               # ISO installer configuration
│       └── default.nix          # Complete installer system
│
├── modules/
│   ├── desktop/                 # Desktop environment modules
│   │   ├── hyprland.nix        # Hyprland configuration
│   │   └── rice.nix            # Theming and aesthetics
│   ├── development/             # Development tools
│   │   ├── editors.nix         # Text editors and IDEs
│   │   ├── languages.nix       # Programming language support
│   │   └── tools.nix           # Development utilities
│   ├── gaming/                  # Gaming optimizations
│   │   ├── graphics.nix        # Graphics drivers and optimizations
│   │   └── steam.nix           # Steam configuration
│   └── hardware/                # Hardware-specific modules
│       └── framework13.nix     # Framework 13 optimizations
│
├── home/
│   └── default.nix             # Home Manager configuration
│
├── overlays/
│   └── default.nix             # Custom package overlays
│
└── packages/
    └── default.nix             # Custom packages and scripts
```

### Module System
Each module is designed to be:
- **Modular**: Can be enabled/disabled independently
- **Configurable**: Accepts options for customization
- **Tested**: Verified to work with the system
- **Documented**: Clear comments and documentation

### Configuration Philosophy
- **Declarative**: All system state defined in configuration files
- **Reproducible**: Same configuration produces identical systems
- **Version Controlled**: All changes tracked in Git
- **Modular**: Components can be mixed and matched
- **Hardware Agnostic**: Works across different hardware configurations

---

## Build System

### GitHub Actions CI/CD
The project uses GitHub Actions for automated builds:

#### Workflow: `build-iso.yml`
- **Trigger**: Every push to main branch
- **Runner**: Latest Ubuntu with Nix installed
- **Build Time**: ~15-20 minutes
- **Output**: ISO file uploaded as artifact

#### Build Process
1. **Setup**: Install Nix with flakes support
2. **Cache**: Configure Cachix for faster builds
3. **Build**: Execute `nix build .#installer-iso`
4. **Artifact**: Upload ISO with version naming
5. **Release**: Automatic releases on tags

#### Build Command
```bash
nix build .#installer-iso --accept-flake-config
```

#### Cache Configuration
- Uses Cachix for binary cache
- Reduces build times significantly
- Shared cache across builds

### Local Development
For local development and testing:

#### Prerequisites
- NixOS or Nix package manager
- Flakes support enabled
- Git for version control

#### Build Commands
```bash
# Build ISO locally
nix build .#installer-iso

# Build specific host configuration
nix build .#nixosConfigurations.aetherbook.config.system.build.toplevel

# Check flake configuration
nix flake check

# Update dependencies
nix flake update

# Show flake info
nix flake show
```

#### Development Shell
```bash
# Enter development environment
nix develop

# Available tools:
- nixpkgs-fmt    # Nix code formatter
- statix         # Nix linter
- deadnix        # Dead code detector
```

### Reproducible Builds
- **Flake.lock**: Pins all dependencies to specific commits
- **Fixed Inputs**: All external dependencies specified
- **Deterministic**: Same inputs produce identical outputs
- **Verification**: Builds can be verified across machines

---

## Hardware Support

### Framework 13 Optimizations
The system includes specific optimizations for Framework 13 laptops:

#### Power Management
```nix
# TLP configuration for optimal battery life
services.tlp = {
  enable = true;
  settings = {
    CPU_SCALING_GOVERNOR_ON_AC = "performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    START_CHARGE_THRESH_BAT0 = 40;
    STOP_CHARGE_THRESH_BAT0 = 80;
  };
};
```

#### Hardware Features
- **Fingerprint Reader**: Framework 13 fingerprint sensor support
- **Expansion Cards**: USB-C, HDMI, DisplayPort, etc.
- **Audio**: High-quality audio with PipeWire
- **WiFi**: Intel AX210 wireless support
- **Bluetooth**: Bluetooth 5.2 support
- **Display**: High-DPI scaling support

#### Thermal Management
- **CPU Scaling**: Dynamic frequency scaling
- **Fan Control**: Automatic fan curve optimization
- **Thermal Throttling**: Protection against overheating
- **Sleep States**: S3 sleep support

### Graphics Support
Multi-vendor graphics support for broad hardware compatibility:

#### Intel Graphics
```nix
hardware.opengl = {
  enable = true;
  driSupport = true;
  driSupport32Bit = true;
  extraPackages = with pkgs; [
    intel-media-driver
    vaapiIntel
    vaapiVdpau
    libvdpau-va-gl
  ];
};
```

#### AMD Graphics
- **AMDGPU Driver**: Open source AMD drivers
- **Vulkan Support**: RADV Vulkan driver
- **Video Acceleration**: Hardware video decoding

#### NVIDIA Graphics
- **Proprietary Drivers**: Latest NVIDIA drivers
- **CUDA Support**: CUDA toolkit for development
- **Optimus**: NVIDIA Optimus support for laptops

### Stability Features
To ensure stable operation in live environment:

#### Kernel Parameters
```nix
boot.kernelParams = [
  "iommu=pt"                    # Improved IOMMU performance
  "intel_iommu=on"             # Intel IOMMU support
  "i915.enable_psr=0"          # Disable PSR to prevent flickering
  "i915.enable_fbc=0"          # Disable framebuffer compression
  "nouveau.modeset=0"          # Disable nouveau for NVIDIA systems
];
```

#### Graphics Stability
```bash
# Environment variables for Wayland stability
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER_ALLOW_SOFTWARE=1
export XCURSOR_SIZE=24
```

---

## Desktop Environment

### Hyprland Configuration
Hyprland is the primary window manager, configured for productivity and aesthetics:

#### Core Features
- **Tiling Window Manager**: Automatic window arrangement
- **Wayland Native**: Modern display protocol
- **Hardware Acceleration**: GPU-accelerated rendering
- **Multi-Monitor**: Full multi-monitor support
- **Animations**: Smooth window animations

#### Keybindings
Essential keybindings for system control:

```bash
# System Controls
SUPER + Q           # Close window
SUPER + M           # Exit Hyprland
SUPER + V           # Toggle floating
SUPER + P           # Toggle pseudo-tiling
SUPER + J           # Toggle split orientation
SUPER + F           # Toggle fullscreen

# Application Launchers
SUPER + Return      # Open terminal (Kitty)
SUPER + D           # Application launcher (rofi/wofi)
SUPER + B           # Open browser (Brave)
SUPER + E           # File manager
SUPER + C           # VSCode
SUPER + G           # Steam
SUPER + T           # Discord

# Window Management
SUPER + [1-9]       # Switch to workspace
SUPER + SHIFT + [1-9] # Move window to workspace
SUPER + [hjkl]      # Move focus
SUPER + SHIFT + [hjkl] # Move windows

# System Functions
SUPER + L           # Lock screen
SUPER + SHIFT + E   # Logout menu
Print Screen        # Screenshot
ALT + Print Screen  # Window screenshot
```

#### Workspace Configuration
- **10 Workspaces**: Numbered 1-9, 0
- **Dynamic**: Workspaces created as needed
- **Per-Monitor**: Independent workspaces per monitor
- **Persistent**: Workspace state maintained

#### Window Rules
Automatic window management for common applications:
```nix
# Steam windows
windowrule = "workspace 4,^(steam)$"
windowrule = "float,^(steam)$,title:^(Friends List)$"

# Development
windowrule = "workspace 2,^(code)$"
windowrule = "workspace 3,^(brave)$"

# Gaming
windowrule = "fullscreen,^(steam_app_).*"
windowrule = "workspace 4,^(steam_app_).*"
```

### Status Bar (Waybar)
System monitoring and status display:
- **System Stats**: CPU, memory, disk usage
- **Network**: Connection status and traffic
- **Audio**: Volume control and device selection
- **Date/Time**: Clock with calendar popup
- **Workspaces**: Visual workspace indicator
- **Tray**: System tray for applications

### Application Launcher
Multiple launcher options:
- **rofi**: Traditional application launcher
- **wofi**: Wayland-native launcher
- **Custom Scripts**: Quick access to common functions

---

## Development Environment

### Editors and IDEs
Multiple editor options for different workflows:

#### Visual Studio Code
Pre-configured with popular extensions:
- **Language Support**: Nix, Python, Rust, Go, TypeScript
- **Git Integration**: Built-in Git support
- **Debugging**: Multi-language debugging support
- **Extensions**: Pre-installed productivity extensions

#### Terminal Tools
Modern terminal-based development tools:
- **Kitty**: GPU-accelerated terminal emulator
- **Zsh**: Advanced shell with completions
- **Git**: Version control with enhanced diff tools
- **Neovim**: Modal text editor (optional)

### Programming Languages
Built-in support for major programming languages:

#### System Languages
- **Nix**: System configuration language
- **Bash/Zsh**: System scripting

#### Development Languages
- **Python**: Full Python ecosystem
- **Rust**: Rust toolchain with Cargo
- **Go**: Go compiler and tools
- **JavaScript/TypeScript**: Node.js ecosystem
- **C/C++**: GCC and Clang toolchains

#### Package Managers
- **npm/yarn**: JavaScript package management
- **pip**: Python package management
- **cargo**: Rust package management
- **go mod**: Go module management

### Development Tools
Essential tools for software development:

#### Version Control
- **Git**: Distributed version control
- **GitHub CLI**: Command-line GitHub integration
- **Git-delta**: Enhanced diff viewer

#### Build Tools
- **Make**: Traditional build system
- **CMake**: Cross-platform build system
- **Meson**: Modern build system
- **Nix**: Reproducible builds

#### Debugging and Profiling
- **GDB**: GNU debugger
- **Valgrind**: Memory debugging
- **Perf**: Performance profiling
- **Strace**: System call tracing

---

## Gaming Configuration

### Steam Integration
Comprehensive Steam setup for gaming:

#### Steam Features
- **Proton Support**: Windows game compatibility
- **Steam Input**: Controller configuration
- **Steam Remote Play**: Game streaming
- **Steam Workshop**: Community content

#### Proton Configuration
```nix
programs.steam = {
  enable = true;
  remotePlay.openFirewall = true;
  dedicatedServer.openFirewall = true;
  gamescopeSession.enable = true;
};
```

#### Gaming Dependencies
Essential libraries for game compatibility:
- **32-bit Graphics**: Multi-lib graphics drivers
- **Audio Libraries**: PulseAudio/PipeWire 32-bit
- **Input Libraries**: SDL2, DirectInput support
- **Vulkan**: 32-bit Vulkan drivers

### Graphics Optimization
Performance optimizations for gaming:

#### GPU Drivers
- **Intel**: Latest Mesa drivers with performance patches
- **AMD**: AMDGPU with RADV Vulkan driver
- **NVIDIA**: Proprietary drivers with CUDA support

#### Performance Features
- **GameMode**: Automatic performance optimization
- **CPU Governor**: Dynamic performance scaling
- **Memory Management**: Optimized memory allocation
- **I/O Scheduling**: Low-latency disk access

### Gaming Applications
Pre-installed gaming tools:

#### Game Launchers
- **Steam**: Primary gaming platform
- **Prism Launcher**: Minecraft launcher with mod support
- **chiaki-ng**: PlayStation Remote Play client

#### Gaming Utilities
- **Discord**: Voice chat and gaming communities
- **OBS Studio**: Game streaming and recording
- **MangoHud**: Performance overlay
- **Gamescope**: Gaming compositor

### Controller Support
Multi-controller support for gaming:
- **Xbox Controllers**: Wired and wireless support
- **PlayStation Controllers**: DS4 and DualSense support
- **Nintendo Controllers**: Switch Pro Controller support
- **Generic Controllers**: Wide compatibility

---

## Installation Guide

### Prerequisites
Before installing ShinigamiNix:

#### Hardware Requirements
- **CPU**: x86_64 processor (Intel/AMD)
- **RAM**: Minimum 4GB, recommended 8GB+
- **Storage**: Minimum 20GB available space
- **Graphics**: Any modern graphics card
- **UEFI**: UEFI firmware (Legacy BIOS supported)

#### Preparation
1. **Backup Data**: Backup important files
2. **USB Drive**: 8GB+ USB drive for installer
3. **Internet**: Stable internet connection
4. **Power**: Ensure adequate power (laptops)

### Creating Installation Media

#### Download ISO
1. Visit the [GitHub Releases](https://github.com/SysGrimm/ShinigamiNix/releases)
2. Download the latest `ShinigamiNix-installer.iso`
3. Verify the download (checksums provided)

#### Write to USB
##### On Linux:
```bash
# Replace /dev/sdX with your USB device
sudo dd if=ShinigamiNix-installer.iso of=/dev/sdX bs=4M status=progress
sync
```

##### On Windows:
- Use Rufus, Etcher, or similar tool
- Select the ISO file and USB drive
- Write in DD mode for best compatibility

##### On macOS:
```bash
# Find the USB device
diskutil list

# Unmount and write (replace diskX)
diskutil unmountDisk /dev/diskX
sudo dd if=ShinigamiNix-installer.iso of=/dev/rdiskX bs=4m
```

### Boot Process

#### UEFI Boot
1. Insert USB drive
2. Restart computer
3. Access UEFI/BIOS settings (F2, F12, Del)
4. Set USB as first boot device
5. Save and restart

#### Boot Options
- **Normal Boot**: Standard installation environment
- **Safe Mode**: Fallback graphics mode
- **Memory Test**: Hardware diagnostics

### Installation Process

#### Step 1: Boot to Live Environment
1. Boot from USB drive
2. Wait for ShinigamiNix to load
3. Hyprland desktop will appear
4. Open terminal with `SUPER + Return`

#### Step 2: Partition Disk
Use the GUI partition manager:
```bash
# Open GParted
gparted
```

Recommended partition scheme:
- **EFI System**: 512MB, FAT32, `/boot/efi`
- **Root**: Remaining space, ext4, `/`
- **Swap**: Optional, 2x RAM size

Or use command line:
```bash
# Example for /dev/sda
sudo parted /dev/sda -- mklabel gpt
sudo parted /dev/sda -- mkpart root ext4 512MB -8GB
sudo parted /dev/sda -- mkpart swap linux-swap -8GB 100%
sudo parted /dev/sda -- mkpart ESP fat32 1MB 512MB
sudo parted /dev/sda -- set 3 esp on

# Format partitions
sudo mkfs.ext4 -L nixos /dev/sda1
sudo mkswap -L swap /dev/sda2
sudo mkfs.fat -F 32 -n boot /dev/sda3
```

#### Step 3: Mount Filesystems
```bash
# Mount root filesystem
sudo mount /dev/disk/by-label/nixos /mnt

# Create and mount boot directory
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/boot /mnt/boot

# Enable swap
sudo swapon /dev/sda2
```

#### Step 4: Install System
Use the guided installer:
```bash
# Run guided installation
quick-install
```

This will:
1. Check filesystem configuration
2. Verify network connectivity
3. Download and install ShinigamiNix
4. Configure bootloader
5. Provide post-installation instructions

#### Step 5: Post-Installation
After successful installation:

1. **Set Root Password**:
```bash
sudo nixos-enter --root /mnt -c 'passwd'
```

2. **Create User Account**:
```bash
sudo nixos-enter --root /mnt -c 'useradd -m -G wheel username'
sudo nixos-enter --root /mnt -c 'passwd username'
```

3. **Reboot**:
```bash
reboot
```

4. **Remove USB Drive**: Remove installation media

### First Boot
After rebooting:
1. System boots to ShinigamiNix
2. Login with created user account
3. Hyprland desktop environment starts
4. All applications available immediately

---

## Troubleshooting

### Common Installation Issues

#### Network Connectivity
If network issues occur during installation:

```bash
# Check network status
fix-network

# Manual WiFi setup
nmtui

# Check connectivity
ping google.com
```

#### Filesystem Problems
If filesystem configuration fails:

```bash
# Diagnose filesystem issues
fix-filesystems

# Manual configuration generation
sudo nixos-generate-config --root /mnt --force

# Check mounts
lsblk
mount | grep /mnt
```

#### Graphics Issues
If graphics display problems occur:

1. **Boot in Safe Mode**: Use fallback graphics
2. **Check Drivers**: Verify graphics driver compatibility
3. **Disable Hardware Acceleration**: Use software rendering

```bash
# Disable hardware cursors
export WLR_NO_HARDWARE_CURSORS=1

# Use software rendering
export WLR_RENDERER_ALLOW_SOFTWARE=1
```

### Boot Issues

#### UEFI Boot Problems
- **Secure Boot**: Disable Secure Boot in UEFI settings
- **Boot Order**: Ensure USB is first in boot order
- **Legacy Mode**: Switch to UEFI mode if using Legacy

#### Kernel Panics
- **Hardware**: Check hardware compatibility
- **Memory**: Run memory test
- **Graphics**: Try different graphics modes

### Performance Issues

#### Slow Boot
- **Hardware**: Check disk health
- **Services**: Disable unnecessary services
- **Graphics**: Verify graphics acceleration

#### Gaming Performance
- **Drivers**: Ensure latest graphics drivers
- **GameMode**: Verify GameMode is running
- **CPU Governor**: Check performance scaling

### System Maintenance

#### Update System
```bash
# Update flake inputs
sudo nix flake update /etc/nixos

# Rebuild system
sudo nixos-rebuild switch

# Garbage collection
sudo nix-collect-garbage -d
```

#### Debug System
```bash
# Check system logs
journalctl -b

# Check specific service
systemctl status service-name

# Hardware information
lshw -short
```

---

## Development & Contributing

### Development Environment
Setting up development environment for contributing:

#### Prerequisites
- NixOS or Nix package manager
- Git for version control
- Text editor (VSCode recommended)
- GitHub account for contributions

#### Clone Repository
```bash
git clone https://github.com/SysGrimm/ShinigamiNix.git
cd ShinigamiNix
```

#### Development Shell
```bash
# Enter development environment
nix develop

# Available tools:
- nixpkgs-fmt    # Format Nix code
- statix         # Lint Nix code
- deadnix        # Find dead code
```

### Testing Changes

#### Local Testing
```bash
# Check flake validity
nix flake check

# Build configuration
nix build .#nixosConfigurations.aetherbook.config.system.build.toplevel

# Build installer ISO
nix build .#installer-iso

# Test in VM
nixos-rebuild build-vm --flake .#aetherbook
```

#### Virtual Machine Testing
```bash
# Build VM configuration
nix build .#nixosConfigurations.aetherbook.config.system.build.vm

# Run VM
./result/bin/run-*-vm
```

### Code Standards

#### Nix Code Style
- Use nixpkgs-fmt for formatting
- Follow nixpkgs conventions
- Add comments for complex configurations
- Keep modules focused and modular

#### Documentation
- Update wiki.md for significant changes
- Add comments to complex configurations
- Document new features and options
- Maintain troubleshooting section

### Contribution Workflow

#### Making Changes
1. **Fork Repository**: Create personal fork
2. **Create Branch**: Feature/fix branch
3. **Make Changes**: Implement improvements
4. **Test Changes**: Verify functionality
5. **Submit PR**: Create pull request

#### Pull Request Guidelines
- **Clear Description**: Explain changes made
- **Testing**: Include testing information
- **Documentation**: Update relevant documentation
- **Breaking Changes**: Note any breaking changes

### Build System Maintenance

#### GitHub Actions
The build system is automated via GitHub Actions:

##### Workflow Maintenance
- **Dependencies**: Keep actions up to date
- **Secrets**: Manage build secrets securely
- **Cache**: Optimize build cache usage
- **Artifacts**: Manage artifact retention

##### Adding New Builds
To add new build configurations:
1. Add new nixosConfiguration to flake.nix
2. Update build matrix in GitHub Actions
3. Test build locally first
4. Document new configuration

### Release Process

#### Version Management
- **Semantic Versioning**: Follow semver principles
- **Git Tags**: Tag releases in Git
- **Release Notes**: Document changes
- **Artifacts**: Attach built ISOs

#### Release Checklist
1. Update version numbers
2. Update documentation
3. Test all configurations
4. Create release notes
5. Tag release in Git
6. Verify automated builds
7. Announce release

---

## Appendix

### Configuration Examples

#### Custom User Configuration
Example user configuration for ShinigamiNix:

```nix
{ config, pkgs, ... }:

{
  # User account
  users.users.myuser = {
    isNormalUser = true;
    description = "My User";
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    packages = with pkgs; [
      # Additional user packages
      firefox
      thunderbird
      libreoffice
    ];
  };

  # Custom services
  systemd.user.services.my-service = {
    description = "My custom service";
    wantedBy = [ "default.target" ];
    script = "echo 'Hello from my service'";
  };
}
```

#### Hardware-Specific Overrides
Example hardware-specific configuration:

```nix
{ config, lib, pkgs, ... }:

{
  # Hardware-specific kernel parameters
  boot.kernelParams = [
    "acpi_backlight=vendor"    # Fix backlight control
    "intel_pstate=active"      # Intel P-State driver
  ];

  # Hardware-specific services
  services.thermald.enable = lib.mkIf (config.hardware.cpu.intel) true;
  
  # Power management
  powerManagement.cpuFreqGovernor = "powersave";
}
```

### Useful Commands Reference

#### System Management
```bash
# Rebuild system
sudo nixos-rebuild switch --flake .

# Build without switching
sudo nixos-rebuild build --flake .

# Test configuration
sudo nixos-rebuild test --flake .

# Boot into previous generation
sudo nixos-rebuild switch --rollback

# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Delete old generations
sudo nix-collect-garbage -d
```

#### Package Management
```bash
# Search packages
nix search nixpkgs package-name

# Install package temporarily
nix shell nixpkgs#package-name

# Run package
nix run nixpkgs#package-name

# Update flake inputs
nix flake update

# Show flake outputs
nix flake show
```

#### Development
```bash
# Enter development shell
nix develop

# Build specific output
nix build .#package-name

# Check flake
nix flake check

# Format Nix files
nixpkgs-fmt **/*.nix

# Lint Nix files
statix check
```

### External Resources

#### Documentation
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Package Manager Manual](https://nixos.org/manual/nix/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Hyprland Documentation](https://hyprland.org/)

#### Community
- [NixOS Discourse](https://discourse.nixos.org/)
- [NixOS Reddit](https://reddit.com/r/NixOS)
- [NixOS Matrix](https://matrix.to/#/#nix:nixos.org)
- [Hyprland Discord](https://discord.gg/hQ9XvMUjjr)

#### Development
- [Nixpkgs Repository](https://github.com/NixOS/nixpkgs)
- [NixOS Configuration Examples](https://github.com/NixOS/nixos-hardware)
- [Home Manager Examples](https://github.com/nix-community/home-manager)

---

*Last updated: 2025-09-07*
*Version: 1.0.0*
*Maintainer: SysGrimm*
