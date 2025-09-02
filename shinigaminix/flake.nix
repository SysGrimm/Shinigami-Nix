{
  description = "ShinigamiNix - NixOS configuration for Framework 13 development and gaming";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware support
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Gaming
    nix-gaming.url = "github:fufexan/nix-gaming";

    # Theming
    stylix.url = "github:danth/stylix";
  };

  outputs = { 
    self, 
    nixpkgs, 
    nixpkgs-stable,
    home-manager, 
    hyprland, 
    nixos-hardware,
    nix-gaming,
    stylix,
    ... 
  } @ inputs: {
    # NixOS configuration
    nixosConfigurations = {
      aetherbook = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { 
          inherit inputs; 
          pkgs-stable = import nixpkgs-stable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        };
        modules = [
          # Hardware
          ./hosts/aetherbook/hardware-configuration.nix
          nixos-hardware.nixosModules.framework-13-7040-amd

          # Main configuration
          ./hosts/aetherbook/default.nix

          # Home Manager
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.reaper = import ./home/default.nix;
            home-manager.extraSpecialArgs = { inherit inputs; };
          }

          # Hyprland
          hyprland.nixosModules.default

          # Theming
          stylix.nixosModules.stylix

          # Gaming
          nix-gaming.nixosModules.steamCompat
        ];
      };
    };

    # Development shell
    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      buildInputs = with nixpkgs.legacyPackages.x86_64-linux; [
        nixpkgs-fmt
        nil
        git
        home-manager
      ];
      shellHook = ''
        echo "Welcome to ShinigamiNix development environment!"
        echo "Use 'nixos-rebuild switch --flake .' to apply configuration"
      '';
    };

    # Custom packages
    packages.x86_64-linux = import ./packages { pkgs = nixpkgs.legacyPackages.x86_64-linux; };
  };
}
