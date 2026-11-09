{...}: {
  imports = [./modules/common.nix];

  programs = {
    git.settings.user.email = "felipe@si9sistemas.com";
  };
}
