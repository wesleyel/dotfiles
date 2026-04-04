{
  description = "Rebuildable nix-darwin template for wesleydeMac-mini";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixpkgs, nix-darwin, home-manager, ... }:
    let
      hostname = "wesleydeMac-mini";
      username = "wesley";
      system = "aarch64-darwin";
      mirrorConfig = import ./modules/regions/china-mirror.nix;

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      specialArgs = {
        inherit hostname inputs mirrorConfig system username;
      };
    in
    {
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        inherit specialArgs system;
        modules = [
          ./hosts/darwin/${hostname}
          home-manager.darwinModules.home-manager
          {
            nixpkgs = {
              hostPlatform = system;
              config.allowUnfree = true;
            };

            users.users.${username}.home = "/Users/${username}";

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = false;
              backupFileExtension = "hm-backup";
              extraSpecialArgs = specialArgs;
              users.${username} = import ./home;
            };
          }
        ];
      };

      homeConfigurations."${username}@${hostname}" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = specialArgs;
        modules = [ ./home ];
      };
    };
}
