{
  config,
  pkgs,
  ...
}: let
  catppuccinKde = pkgs.catppuccin-kde.override {
    flavour = ["macchiato"];
    accents = ["blue"];
  };
in {
  imports = [./neovim ./tmux.nix];
  home.username = "ferps";
  home.homeDirectory = "/home/ferps";
  home.stateVersion = "25.11"; # Please read the comment before changing.
  home.packages = with pkgs; [
    zathura
  ];

  gtk = {
    enable = true;
    colorScheme = "dark";
    theme = {
      name = "catppuccin-macchiato-blue-standard";
      package = pkgs.catppuccin-gtk.override {
        variant = "macchiato";
        accents = ["blue"];
        size = "standard";
      };
    };
    gtk4.theme = config.gtk.theme;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders.override {
        flavor = "macchiato";
        accent = "blue";
      };
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";
    kvantum = {
      enable = true;
      themes = [
        (pkgs.catppuccin-kvantum.override {
          variant = "macchiato";
          accent = "blue";
        })
      ];
      settings.General.theme = "catppuccin-macchiato-blue";
    };
    qt6ctSettings.Appearance = {
      style = "kvantum";
      icon_theme = "Papirus-Dark";
    };
  };

  # Apps KDE (Dolphin, Ark) leem as cores e os ícones daqui, mesmo fora do Plasma.
  # Sem [UiSettings], o KColorSchemeManager aplica uma paleta Breeze por cima do
  # Kvantum, e o Dolphin fica com o texto ilegível.
  xdg.dataFile."color-schemes/CatppuccinMacchiatoBlue.colors".source = "${catppuccinKde}/share/color-schemes/CatppuccinMacchiatoBlue.colors";
  xdg.configFile."kdeglobals".source = pkgs.runCommand "kdeglobals" {} ''
    cat ${catppuccinKde}/share/color-schemes/CatppuccinMacchiatoBlue.colors > $out
    printf '\n[Icons]\nTheme=Papirus-Dark\n\n[UiSettings]\nColorScheme=CatppuccinMacchiatoBlue\n' >> $out
  '';
}
