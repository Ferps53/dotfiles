{
  config,
  pkgs,
  ...
}: {
  imports = [./neovim ./tmux.nix];
  home.username = "ferps";
  home.homeDirectory = "/home/ferps";
  home.stateVersion = "25.11"; # Please read the comment before changing.
  home.packages = with pkgs; [
    zathura
  ];
}
