{
  config,
  pkgs,
  lib,
  ...
}: let
  nvimDir = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/home/modules/neovim";
in {
  home = {
    packages = with pkgs; [
      lua-language-server
      nil
      typescript-language-server
      svelte-language-server
      prisma-language-server
      zls
      jdt-language-server
      angular-language-server
      hyprls
      lemminx
      alejandra
      google-java-format
      prettier
      biome
      ripgrep
      fd
      fzf
      bat
      tree-sitter
      lldb
    ];

    sessionVariables.EDITOR = "nvim";
    shellAliases = {
      vim = "nvim";
      vi = "nvim";
    };
  };

  xdg.configFile."nvim" = {
    source = nvimDir;
  };
}
