# ShinigamiNix Wiki

## Project Overview
ShinigamiNix is a NixOS configuration project optimized for the 2025 Framework 13 laptop, focused on development and gaming with Hyprland as the tiling window manager.

**Key Components:**
- **Hardware**: Framework 13 (2025 model)
- **OS**: NixOS
- **Window Manager**: Hyprland (Wayland-based tiling WM)
- **Primary Use Cases**: Development and Gaming
- **Repository**: https://gitea.osiris-adelie.ts.net/reaper/shinigaminix
- **Target Device**: aetherbook.osiris-adelie.ts.net

## System Architecture
This project manages a NixOS configuration with:
- **Display Layer**: Hyprland on Wayland with hardware acceleration
- **Development Layer**: Optimized development tools and workflow
- **Gaming Layer**: Steam, graphics drivers, and gaming optimizations
- **Hardware Layer**: Framework 13 specific optimizations

## Configuration Structure
```
shinigaminix/
├── wiki.md                    # This documentation
├── flake.nix                  # Main flake configuration
├── flake.lock                 # Lock file for reproducible builds
├── hosts/
│   └── aetherbook/            # Host-specific configuration
│       ├── default.nix        # Main host configuration
│       └── hardware-configuration.nix  # Hardware-specific settings
├── modules/
│   ├── desktop/               # Desktop environment modules
│   │   ├── hyprland.nix      # Hyprland configuration
│   │   └── rice.nix          # Theming and aesthetics
│   ├── development/           # Development tools
│   │   ├── editors.nix       # Text editors and IDEs
│   │   ├── languages.nix     # Programming language support
│   │   └── tools.nix         # Development utilities
│   ├── gaming/                # Gaming optimizations
│   │   ├── steam.nix         # Steam configuration
│   │   └── graphics.nix      # Graphics drivers and optimizations
│   └── hardware/              # Hardware-specific modules
│       └── framework13.nix   # Framework 13 specific optimizations
└── overlays/                  # Custom package overlays
    └── default.nix           # Custom packages and modifications
```

## Framework 13 Optimizations
- Intel 13th gen CPU optimizations
- Power management and battery life
- Framework-specific hardware support
- Thermal management
- USB-C and expansion card support

## Hyprland Configuration
- Wayland-native tiling window manager
- Hardware-accelerated rendering
- Custom keybindings for development workflow
- Workspace management
- Rice (aesthetic customization)

## Development Environment
- Multi-language support (Nix, Python, Rust, Go, etc.)
- Modern editors (Neovim, VSCode, etc.)
- Development tools and utilities
- Git integration
- Terminal emulators and shell configuration

## Gaming Setup
- Steam with Proton support
- Graphics drivers optimization
- Game-specific tweaks
- Performance monitoring
- Controller support

## Common Commands
### System Management
```bash
# Rebuild and switch configuration
sudo nixos-rebuild switch --flake .

# Build without switching
sudo nixos-rebuild build --flake .

# Update flake inputs
nix flake update

# Garbage collection
sudo nix-collect-garbage -d
```

### Development Workflow
```bash
# Enter development shell
nix develop

# Run application from flake
nix run .#<application>

# Format Nix files
nixpkgs-fmt **/*.nix
```

## Issue Resolution Log
*Issues and their resolutions will be documented here as they occur*

## Configuration Changes Log
*All system changes will be documented here with timestamps and rationale*

### 2025-01-02 - Initial Configuration
**Problem Description:** Starting from scratch to create a comprehensive NixOS configuration for Framework 13 laptop optimized for development and gaming.

**Root Cause Analysis:** Need for a modern, reproducible, and optimized NixOS setup that takes advantage of:
- Framework 13 hardware capabilities
- Hyprland tiling window manager for productivity
- Gaming optimizations with Steam and Proton
- Development workflow with modern tools

**Solution Applied:**
1. **Flake Configuration**: Created `flake.nix` with inputs for Hyprland, Home Manager, gaming support, and theming
2. **Framework 13 Optimizations**: 
   - Intel graphics drivers with hardware acceleration
   - TLP power management with AC/battery profiles
   - Framework-specific kernel parameters
   - Expansion card support via udev rules
   - Battery charge thresholds (40-80%)
3. **Hyprland Setup**:
   - Wayland-native configuration with hardware acceleration
   - Custom keybindings optimized for development
   - Window rules for gaming and productivity apps
   - Waybar status bar with system monitoring
4. **Development Environment**:
   - Neovim with LSP support for multiple languages
   - Git configuration with delta for better diffs
   - Programming languages: Nix, Rust, Go, Python, Node.js, etc.
   - Development tools: Docker, Kubernetes, Terraform, etc.
5. **Gaming Optimizations**:
   - Steam with Proton support and additional dependencies
   - GameMode for performance optimization
   - Graphics drivers with Vulkan support
   - Controller support for various gaming devices
   - Low-latency audio configuration
6. **Rice/Theming**:
   - Tokyo Night color scheme with Stylix
   - Consistent theming across GTK and Qt applications
   - Beautiful fonts including Nerd Fonts
   - Custom cursor and icon themes

**Commands Used:**
```bash
# Initial setup
git remote set-url origin https://gitea.osiris-adelie.ts.net/reaper/shinigaminix
git reset --hard origin/main

# After deployment on NixOS system:
sudo nixos-rebuild switch --flake /home/reaper/shinigaminix
nix flake update  # To update dependencies
```

**Prevention Measures:**
1. All configurations are version controlled in Git
2. Flake.lock ensures reproducible builds
3. Modular structure allows easy maintenance
4. Wiki documentation for all changes
5. Custom scripts for common operations

**Files Created/Modified:**
- `flake.nix` - Main flake configuration
- `hosts/aetherbook/default.nix` - Host-specific configuration
- `hosts/aetherbook/hardware-configuration.nix` - Hardware configuration (placeholder)
- `modules/hardware/framework13.nix` - Framework 13 optimizations
- `modules/desktop/hyprland.nix` - Hyprland configuration
- `modules/desktop/rice.nix` - Theming and aesthetics
- `modules/development/editors.nix` - Editor configurations
- `modules/development/languages.nix` - Programming language support
- `modules/development/tools.nix` - Development tools
- `modules/gaming/steam.nix` - Steam and gaming configuration
- `modules/gaming/graphics.nix` - Graphics optimizations
- `home/default.nix` - Home Manager configuration
- `overlays/default.nix` - Custom package overlays
- `packages/default.nix` - Custom scripts and tools

**Next Steps:**
1. Deploy to actual Framework 13 hardware
2. Generate real hardware-configuration.nix
3. Test all configurations and optimize as needed
4. Set up automated backups and monitoring

---
*Last updated: 2025-01-02*
