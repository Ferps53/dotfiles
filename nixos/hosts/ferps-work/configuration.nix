{ config, pkgs, ... }:

{
  imports = [
    ../../modules/common.nix
    ../../modules/work.nix
  ];

  networking.hostName = "ferps-work";

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
    ];
  };

  system.stateVersion = "25.11";
}
