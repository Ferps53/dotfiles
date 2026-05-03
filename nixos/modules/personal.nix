{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    steam
    wine
    inputs.vintagestory-pr.legacyPackages.${pkgs.system}.vintagestory
  ];

  programs.steam.enable = true;
}
