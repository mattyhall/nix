{ pkgs, lib, config, ... }:
let cfg = config.machine;
in {
  imports = [ (import ./graphical.nix { inherit lib pkgs config; }) ];

  options.machine = {
    hostname = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "laptop";
    };

    extra-packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      example = with pkgs; [ git ];
    };

    extra = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
  };

  config = lib.mkMerge [
    (import ./common.nix {
      inherit pkgs;
      hostname = cfg.hostname;
      extra-packages = cfg.extra-packages;
    })

    cfg.extra
  ];
}

