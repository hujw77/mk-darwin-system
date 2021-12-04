{
  description = "Niv managed apps mkDarwinSystem example";

  inputs = {
    # change tag or commit of nixpkgs for your system
    nixpkgs.url = "github:nixos/nixpkgs/21.11";

    # change main to a tag o git revision
    mk-darwin-system.url = "github:hujw77/mk-darwin-system/main";
    mk-darwin-system.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, mk-darwin-system, ... }:
    let
      darwinFlakeOutput = mk-darwin-system.mkDarwinSystem.m1 {

        # Provide your nix modules to enable configurations on your system.
        #
        modules = [
          # System module
          ({ config, pkgs, ... }: {
            environment.systemPackages = with pkgs; [ nixfmt niv ];
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
            };
          })

          # User module
          ({ pkgs, lib, ... }: {
            home-manager.users."yourUsername" = {
              home.packages = with pkgs; [ KeyttyApp ];

              # Link apps installed by home-manager.
              home.activation = {
                aliasApplications = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                  ln -sfn $genProfilePath/home-path/Applications "$HOME/Applications/HomeManagerApps"
                '';
              };
            };
          })

          ({ lib, ... }: {
            nixpkgs.overlays = let nivSources = import ./nix/sources.nix;
            in [
              (new: old: {
                # You can provide an overlay for packages not available or that fail to compile on arm.
                inherit (nixpkgs.legacyPackages.x86_64-darwin) pandoc niv;

                # Provide apps managed by niv
                KeyttyApp = lib.mds.installNivDmg {
                  name = "Keytty";
                  src = nivSources.KeyttyApp;
                };

              })
            ];
          })

        ];
      };
    in darwinFlakeOutput // {
      # Your custom flake output here.
      nixosConfigurations."your-m1-hostname" =
        darwinFlakeOutput.nixosConfiguration.aarch64-darwin;
    };
}
