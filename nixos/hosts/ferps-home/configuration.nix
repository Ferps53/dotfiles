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

  hardware.graphics.enable = true;
  services.xserver.videoDrivers = ["nvidia"];
  boot.kernelParams = ["nvidia_drm.modeset=1" "nvidia_drm.fbdev=1"];

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  system.stateVersion = "25.11";
}
