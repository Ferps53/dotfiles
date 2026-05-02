{ config, lib, pkgs, inputs, ... }:

{
  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  services = {
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  programs = {
    nix-ld.enable = true;
    hyprland.enable = true;
    fish.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  users.users.ferps = {
    isNormalUser = true;
    uid = 1000;
    description = "Ferps";
    extraGroups = [ "networkmanager" "wheel" "video" "docker" ];
    shell = pkgs.fish;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  nixpkgs.overlays = [
    inputs.neovim-nightly-overlay.overlays.default
  ];

  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  programs.java = {
    enable = true;
    package = pkgs.jdk21; 
  };

  environment = {
    systemPackages = with pkgs; [
      # Ferramentas Base
      git stow firefox kitty blueman networkmanagerapplet pavucontrol
      neovim dunst tmux waybar nautilus wl-clipboard cliphist rofi
      wlogout hyprpaper hyprlock libreoffice ffmpeg docker psmisc spotify discord
      
      # Ferramentas de Dev
      zig nodejs bun openssl prisma-engines
      
      # LSPs, Formatadores e Dependências do Neovim
      alejandra
      nil
      lua-language-server
      typescript-language-server
      svelte-language-server
      prisma/language-server
      zls
      biome
      lemminx
      jdt-language-server
      ripgrep
      fd
      lldb
    ];

    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      
      # Variáveis do Java
      JAVA_8_HOME  = "${pkgs.jdk8}/lib/openjdk";
      JAVA_11_HOME = "${pkgs.jdk11}/lib/openjdk";
      JAVA_17_HOME = "${pkgs.jdk17}/lib/openjdk";
      JAVA_25_HOME = "${pkgs.jdk25}/lib/openjdk";

      # Variáveis do Prisma
      PRISMA_SCHEMA_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/schema-engine";
      PRISMA_QUERY_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/query-engine";
      PRISMA_QUERY_ENGINE_LIBRARY = "${pkgs.prisma-engines}/lib/libquery_engine.node";
      PRISMA_FMT_BINARY = "${pkgs.prisma-engines}/bin/prisma-fmt";
    };
  };

  security.rtkit.enable = true;
  nixpkgs.config.allowUnfree = true;
}
