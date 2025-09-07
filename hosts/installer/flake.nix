{
  description = "NixOS Hyprland Installer ISO";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Add other inputs as needed
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.installer = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./default.nix
      ];
    };
    
    # Build ISO with: nix build .#nixosConfigurations.installer.config.system.build.isoImage
  };
}
