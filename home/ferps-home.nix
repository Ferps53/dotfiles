{...}: {
  imports = [./modules/common.nix ./modules/virtualization];

  programs = {
    git.settings.user.email = "felipebrostolinribeiro@gmail.com";
  };
}
