{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    awscli2
    jetbrains.datagrip
    jetbrains.idea
    visualvm
  ];
}
