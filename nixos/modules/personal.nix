{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    steam
    wine
    vintagestory
  ];

  programs.steam.enable = true;
}
