{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/common.nix
    ../../modules/personal.nix
  ];

  networking.hostName = "ferps-home";
  networking.firewall.allowedTCPPorts = [3000 8081 19000 19001 19002];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  services.xserver.videoDrivers = ["nvidia"];
  boot.kernelParams = ["nvidia_drm.modeset=1" "nvidia_drm.fbdev=1"];

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    powerManagement = {
      enable = true;
    };
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  virtualisation.waydroid.enable = true;
  networking.nftables.enable = true;

  environment.systemPackages = with pkgs; [protonvpn-gui];

  services.power-profiles-daemon.enable = false;

  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
    ANDROID_HOME = "/home/ferps/Android/Sdk";
    ANDROID_SDK_ROOT = "/home/ferps/Android/Sdk";
  };

  system.stateVersion = "25.11";
}
