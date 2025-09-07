{
  description = "SoulBox - Declarative Media Center for Raspberry Pi 5";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Overlay to patch linux-pam for cross-compilation
    linuxPamNoMan = {
      url = "github:numtide/flake-utils";
    };
  };
  
  # Network optimization for CI builds to prevent cache.nixos.org timeouts
  nixConfig = {
    connect-timeout = 60;               # 60s connection timeout (default: 0)
    stalled-download-timeout = 600;     # 10min stall timeout (default: 300s)
    max-jobs = 1;                       # Limit parallel downloads
    cores = 2;                          # Limit CPU cores per job
    extra-substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs = { self, nixpkgs, nixos-hardware, nixos-generators, ... }:
  let
    # Overlay to disable 'man' output for linux-pam when cross-compiling
    pamNoManOverlay = final: prev: {
      linux-pam = prev.linux-pam.overrideAttrs (old: {
        outputs = [ "out" ];
      });
    };
    # Support both native aarch64 builds and cross-compilation from x86_64
    supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
    
    # Helper function to create packages for each system
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    
    # Helper function to create cross-compilation nixpkgs
    mkCrossPkgs = system: import nixpkgs {
      inherit system;
      crossSystem = {
        config = "aarch64-unknown-linux-gnu";
      };
      overlays = [ pamNoManOverlay ];
      config = {
        allowUnsupportedSystem = true;
      };
    };
    
    # Helper function to create native aarch64 nixpkgs
    mkNativePkgs = system: import nixpkgs {
      inherit system;
      config = {
        allowUnsupportedSystem = true;
      };
    };
  in {
    # Base NixOS configurations without image building
    nixosConfigurations = {
      soulbox-pi5 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          "${nixos-hardware}/raspberry-pi/5"
          ./soulbox-nixos-configuration.nix
          {
            # Basic Raspberry Pi 5 configuration
            system.stateVersion = "24.05";
          }
        ];
      };
      
      soulbox-zero2w = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          "${nixos-hardware}/raspberry-pi/zero-2w"
          ./soulbox-zero2w-configuration.nix
          {
            # Basic Pi Zero 2W configuration
            system.stateVersion = "24.05";
          }
        ];
      };
    };
    
    # Use nixos-generators to create SD images - support both x86_64 and aarch64 hosts
    packages = forAllSystems (system: {
      soulbox-pi5-image = nixos-generators.nixosGenerate {
        # Use host system for building (where the build is running)
        system = system;
        # Use cross-compilation pkgs when building from x86_64
        pkgs = if system == "aarch64-linux" 
               then mkNativePkgs system
               else mkCrossPkgs system;
        format = "sd-aarch64";
        modules = [
          "${nixos-hardware}/raspberry-pi/5"
          ./soulbox-nixos-configuration.nix
          {
            # Image-specific configuration - target aarch64
            system.stateVersion = "24.05";
            # Set target system to aarch64 for the generated image
            nixpkgs.system = "aarch64-linux";
            # Enable cross-compilation when building from x86_64
            nixpkgs.crossSystem = nixpkgs.lib.mkIf (system != "aarch64-linux") {
              config = "aarch64-unknown-linux-gnu";
            };
            # Disable problematic binfmt registration for cross-compilation
            boot.binfmt.registrations = {};
          }
        ];
      };
      
      soulbox-zero2w-image = nixos-generators.nixosGenerate {
        # Use host system for building
        system = system;
        pkgs = if system == "aarch64-linux" 
               then mkNativePkgs system
               else mkCrossPkgs system;
        format = "sd-aarch64";
        modules = [
          "${nixos-hardware}/raspberry-pi/zero-2w"
          ./soulbox-zero2w-configuration.nix
          {
            # Image-specific configuration - target aarch64
            system.stateVersion = "24.05";
            # Set target system to aarch64 for the generated image
            nixpkgs.system = "aarch64-linux";
            # Cross-compilation configuration
            nixpkgs.crossSystem = nixpkgs.lib.mkIf (system != "aarch64-linux") {
              config = "aarch64-unknown-linux-gnu";
            };
            # Enable QEMU emulation for cross-compilation
            boot.binfmt.emulatedSystems = nixpkgs.lib.mkIf (system != "aarch64-linux") [ "aarch64-linux" ];
          }
        ];
      };
    });
  };
}
