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
      clang-tools
      jdt-language-server
      kotlin
      (pkgs.callPackage ../../../pkgs/kotlin-lsp.nix {})
      ktlint
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
      stylua
      # codelldb binary lives inside the vscode-lldb extension dir; wrap it onto PATH
      # so nvim-dap-lldb (which defaults to the bare command "codelldb") can find it.
      (pkgs.writeShellScriptBin "codelldb" ''
        exec ${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb "$@"
      '')
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
