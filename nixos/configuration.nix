{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  networking.hostName = "ferps"; # Define your hostname.
  networking.networkmanager.enable = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  hardware = {
    graphics.enable = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  time.timeZone = "America/Sao_Paulo";

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = ["nvidia_drm.modeset=1" "nvidia_drm.fbdev=1"];
  };

  services = {
    xserver = {
      enable = true;
      videoDrivers = ["nvidia"];
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

  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      git
      stow
      firefox
      zig
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
      steam
      psmisc
      spotify
      wlogout
      discord
      hyprpaper
      hyprlock
      libreoffice
      wine
      nodejs
      bun
      openssl
      prisma-engines
      ffmpeg
      docker
      alejandra
      nil
      lua-language-server
      nodePackages.typescript-language-server
      nodePackages.svelte-language-server
      nodePackages."@prisma/language-server"
      zls
      biome
      lemminx
      jdt-language-server
      ripgrep
      fd
      lldb
    ];

    sessionVariables = {
      LIBVA_DRIVER_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY = "nvidia";
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
      PRISMA_SCHEMA_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/schema-engine";
      PRISMA_QUERY_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/query-engine";
      PRISMA_QUERY_ENGINE_LIBRARY = "${pkgs.prisma-engines}/lib/libquery_engine.node";
      PRISMA_FMT_BINARY = "${pkgs.prisma-engines}/bin/prisma-fmt";
    };
  };

  security = {
    rtkit.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  i18n.defaultLocale = "en_US.UTF-8";
  system.stateVersion = "25.11"; # Did you read the comment?
}
