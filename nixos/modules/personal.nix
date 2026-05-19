{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    steam
    wine
    vintagestory
    flutter
    android-studio
    android-tools
  ];

  programs.steam.enable = true;

  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    glib
    gtk3
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.libXtst
    xorg.libXi
    nss
    nspr
    cups
    alsa-lib
    expat
    libdrm
    mesa
    libGL
  ];
}
