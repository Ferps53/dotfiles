{
  config,
  pkgs,
  lib,
  ...
}: {
  home = {
    packages = with pkgs; [
      virt-manager
      virt-viewer
    ];
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };

    "org/virt-manager/virt-manager" = {
      xmleditor-enabled = true;
    };

    "org/virt-manager/virt-manager/new-vm" = {
      cpu-default = "host-passthrough";
    };
  };
}
