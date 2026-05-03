# flake.nix
{
  description = "Minha configuração modular do NixOS (Casa e Empresa)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    vintagestory-pr.url = "github:nixos/nixpkgs/pull/512160/head";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: {
    nixosConfigurations = {
      "ferps-home" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/ferps-home/hardware-configuration.nix
          ./hosts/ferps-home/configuration.nix
        ];
      };

      "ferps-work" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/ferps-work/hardware-configuration.nix
          ./hosts/ferps-work/configuration.nix
        ];
      };
    };
  };
}
