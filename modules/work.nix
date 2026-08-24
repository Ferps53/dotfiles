{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    awscli2
    ssm-session-manager-plugin
    jetbrains.datagrip
    jetbrains.idea
    visualvm
  ];
}
