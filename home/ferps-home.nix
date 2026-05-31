{...}: {
  imports = [./modules/common.nix];

  programs = {
    git.settings.user.email = "felipebrostolinribeiro@gmail.com";
  };
}
