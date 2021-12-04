{ mkDarwinSystem, flake-utils, nixpkgs }: rec {
  m1Systems = [ "x86_64-darwin" ];
  m1Modules = [
    ({ pkgs, ... }: {
      services.nix-daemon.enable = true;
      nix.package = pkgs.nixFlakes;
      nix.extraOptions = ''
        system = x86_64-darwin
        experimental-features = nix-command flakes
        build-users-group = nixbld
      '';
    })
  ];

  apply = { modules ? [ ] }:
    flake-utils.lib.eachSystem m1Systems (system:
      mkDarwinSystem {
        inherit system;
        modules = m1Modules ++ modules;
      });
}
