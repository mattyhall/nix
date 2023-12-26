{...}: {
  imports = [./home.nix ./graphical.nix];

  programs.emacs.enable = true;
  programs.git.userEmail = "me@mattjhall.co.uk";
}
