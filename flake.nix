{
  description = "matt's configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    lumin = {
      url = "git+https://github.com/mattyhall/lumin?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    streamle = {
      url = "sourcehut:~matthall/streamle";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    flake-utils,
    lumin,
    streamle,
  }: let
    utils = flake-utils.lib;
    systems = [utils.system.x86_64-linux utils.system.x86_64-darwin utils.system.aarch64-linux];
  in
    {
      nixosConfigurations = {
        jester = nixpkgs.lib.nixosSystem {modules = [./nixos/jester];};
        barbican = nixpkgs.lib.nixosSystem {modules = [./nixos/barbican];};
        ally-pally = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            ./nixos/ally-pally 
          ];
          specialArgs = { inherit lumin streamle; };
        };
      };

      homeConfigurations = {
        "mjh@jester" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [./home-manager/jester.nix];
        };
        "mjh@rocket" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [./home-manager/rocket.nix];
        };
        "mjh@barbican" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [./home-manager/barbican.nix];
        };
        "mjh@ally-pally" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-linux;
          modules = [./home-manager/ally-pally.nix];
        };
        "mathall@lima-default" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [./home-manager/1936.nix];
        };
      };
    }
    // utils.eachSystem systems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {formatter = pkgs.alejandra;});
}
