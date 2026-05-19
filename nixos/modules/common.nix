{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  networking.networkmanager.enable = true;

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  nix = {
    settings = {
      cores = 8;
      max-jobs = 2;
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

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
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  users.users.ferps = {
    isNormalUser = true;
    uid = 1000;
    description = "Ferps";
    extraGroups = ["networkmanager" "wheel" "video" "docker"];
    shell = pkgs.fish;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  nixpkgs.overlays = [
    inputs.neovim-nightly-overlay.overlays.default
  ];

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      "data-root" = "/home/docker-data";
    };
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  programs.java = {
    enable = true;
    package = pkgs.jdk21;
  };

  programs.direnv.enable = true;

  zramSwap.enable = true;
  zramSwap.algorithm = "zstd";
  zramSwap.memoryPercent = 50; # Ele usará até 50% da sua RAM para criar o dispositivo comprimido

  environment = {
    systemPackages = with pkgs; [
      # Ferramentas Base
      git
      stow
      firefox
      kitty
      blueman
      networkmanagerapplet
      pavucontrol
      neovim
      dunst
      tmux
      waybar
      nautilus
      wl-clipboard
      cliphist
      rofi
      wlogout
      hyprpaper
      hyprlock
      hyprshot
      libreoffice
      ffmpeg
      docker
      psmisc
      spotify
      fastfetch
      discord
      hypridle
      hyprpolkitagent
      playerctl
      brightnessctl
      bibata-cursors
      btop
      direnv
      jq
      libnotify
      zip
      unzip
      (lua5_4.withPackages (ps: with ps; [luasocket]))

      # Ferramentas de Dev
      zig
      nodejs
      bun
      openssl
      prisma-engines
      lombok
      claude-code

      # LSPs, Formatadores e Dependências do Neovim
      alejandra
      nil
      lua-language-server
      typescript-language-server
      svelte-language-server
      prisma-language-server
      zls
      biome
      lemminx
      jdt-language-server
      ripgrep
      fd
      lldb
      angular-language-server
      hyprls
    ];

    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";

      JAVA_8_HOME = "${pkgs.jdk8}/lib/openjdk";
      JAVA_11_HOME = "${pkgs.jdk11}/lib/openjdk";
      JAVA_17_HOME = "${pkgs.jdk17}/lib/openjdk";
      JAVA_21_HOME = "${pkgs.jdk21}/lib/openjdk";
      JAVA_25_HOME = "${pkgs.jdk25}/lib/openjdk";
      LOMBOK_JAR = "${pkgs.lombok}/share/java/lombok.jar";

      PRISMA_SCHEMA_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/schema-engine";
      PRISMA_QUERY_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/query-engine";
      PRISMA_QUERY_ENGINE_LIBRARY = "${pkgs.prisma-engines}/lib/libquery_engine.node";
      PRISMA_FMT_BINARY = "${pkgs.prisma-engines}/bin/prisma-fmt";
    };

    pathsToLink = ["/share/hypr"];
  };
  security.rtkit.enable = true;
  nixpkgs.config.allowUnfree = true;
}
