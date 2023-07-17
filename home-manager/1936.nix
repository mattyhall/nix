{lib, ...}: {
  imports = [./home.nix];

  programs.git.userEmail = "matt.hall@couchbase.com";

  home = {
    username = lib.mkForce "mathall";
    homeDirectory = lib.mkForce "/home/mathall.linux";
  };
}
