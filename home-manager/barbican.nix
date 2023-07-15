{...}: {
  imports = [./home.nix];

  programs.git.userEmail = "matthew@quickbeam.me.uk";
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
