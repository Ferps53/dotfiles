{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    steam
    spotify
    discord
    wine
  ];

  programs.steam.enable = true;
}
