{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    steam
    wine
    (import inputs.vintagestory-pr {
      system = pkgs.system;
      config.allowUnfree = true;
    }).vintagestory
  ];

  programs.steam.enable = true;
}
