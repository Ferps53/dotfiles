{
  description = "Ferps NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      
      notebook = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [ 
          ./hosts/notebook/hardware-configuration.nix
          ./configuration.nix
        ];
      };

      pc-trabalho = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [ 
          ./hosts/pc-trabalho/hardware-configuration.nix
          ./configuration.nix
        ];
      };

    };
  };
}
