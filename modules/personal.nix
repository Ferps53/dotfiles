{
  pkgs,
  inputs,
  ...
}: {
  imports = [./flutter.nix];

  environment.systemPackages = with pkgs; [
    steam
    wine
    vintagestory
    android-studio
    android-tools
  ];

  programs = {
    steam.enable = true;
    dconf.enable = true;

    nix-ld.libraries = with pkgs; [
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
  };

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
      qemu.runAsRoot = false;
    };
  };

  users.users.ferps.extraGroups = ["libvirtd" "kvm" "plugdev"];
}
