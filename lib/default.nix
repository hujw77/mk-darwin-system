{ nixpkgs, ... }:
{ pkgs, lib, ... }:
{

  mkOutOfStoreSymlink = import ./out-symlink.nix { inherit pkgs lib; };
  installNivDmg = import ./install-dmg.nix { inherit pkgs lib; };
  shellEnv = import ./shell-env.nix { inherit pkgs; };

}
