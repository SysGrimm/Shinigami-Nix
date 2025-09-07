{
  description = "ShinigamiNix - Custom NixOS distribution with Hyprland for gaming and development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
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

  outputs = { self, nixpkgs, nixos-hardware, nixos-generators, hyprland, ... }:
  let
    supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in {
    # NixOS configurations
    nixosConfigurations = {
      # Installer ISO configuration
      installer = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inputs = { inherit hyprland; }; };
        modules = [
          ./hosts/installer/default.nix
        ];
      };
      
      # Framework 13 host configuration
      aetherbook = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inputs = { inherit hyprland; }; };
        modules = [
          nixos-hardware.nixosModules.framework-13-7040-amd
          ./hosts/aetherbook/default.nix
          ./modules/hardware/framework13.nix
          ./modules/desktop/hyprland.nix
          ./modules/development
          ./modules/gaming
        ];
      };
    };

    # Package outputs
    packages = forAllSystems (system: {
      # Installer ISO
      installer-iso = nixos-generators.nixosGenerate {
        system = system;
        format = "iso";
        modules = [
          ./hosts/installer/default.nix
          {
            # ISO-specific configuration
            system.stateVersion = "24.05";
            # Allow unfree packages for Steam, etc.
            nixpkgs.config.allowUnfree = true;
          }
        ];
        specialArgs = { 
          inputs = { inherit hyprland; };
        };
      };
      
      # Default package
      default = self.packages.${system}.installer-iso;
    });

    # Development shell
    devShells = forAllSystems (system: {
      default = nixpkgs.legacyPackages.${system}.mkShell {
        buildInputs = with nixpkgs.legacyPackages.${system}; [
          nixpkgs-fmt
          statix
          deadnix
        ];
      };
    });
  };
}
