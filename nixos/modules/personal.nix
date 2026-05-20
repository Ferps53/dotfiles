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
    libx11
    libxext
    libxrender
    libxtst
    libxi
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
