{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    awscli2
    jetbrains.idea
    visualvm
  ];
}
