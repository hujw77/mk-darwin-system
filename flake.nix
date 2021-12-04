{
  description = "Create a nixFlakes + nix-darwin + home-manager system";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/21.11";

    nur.url = "github:nix-community/NUR";

    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.nixpkgs.follows = "nixpkgs";

    # fenix.url = "github:nix-community/fenix";
    # fenix.inputs.nixpkgs.follows = "nixpkgs";


    # emacs-overlay.url = "github:nix-community/emacs-overlay";

    # flake-registry.url = "github:NixOS/flake-registry";
    # flake-registry.flake = false;

    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let
      mkDarwinSystem = import ./lib/mkDarwinSystem.nix
        (inputs // { mk-darwin-system = self; });
        m1 = import ./lib/m1.nix { inherit mkDarwinSystem flake-utils nixpkgs; };
        mkFunctor = f: nixpkgs.lib.setFunctionArgs f (nixpkgs.lib.functionArgs f);

        templates = {
          minimal = {
            description = "mkDarwinSystem minimal example";
            path = ./templates/minimal;
          };

          dev-envs = {
            description = "mkDarwinSystem development environments example";
            path = ./templates/dev-envs;
          };

          niv-managed-apps = {
            description = "mkDarwinSystem with macos apps managed with niv";
            path = ./templates/niv-managed-apps;
          };
        };
    in {
      inherit templates;
      defaultTemplate = templates.minimal;

      mkDarwinSystem = (mkFunctor mkDarwinSystem) // {
        m1 = m1.apply;
        lib = import ./lib { inherit nixpkgs; };
      };

      devShell.aarch64-darwin = let
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        intelPkgs = nixpkgs.legacyPackages.x86_64-darwin;
      in pkgs.mkShell { packages = [ pkgs.nixfmt intelPkgs.niv ]; };
    };
}
