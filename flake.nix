{
  description = "Nix package for VectorCraft, built from the upstream source";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    vectorcraft-src = {
      url = "github:storytold/vectorcraft";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, vectorcraft-src }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      vectorcraft = pkgs.callPackage ./package.nix { inherit vectorcraft-src; };
    in
    {
      packages.${system} = {
        default = vectorcraft;
        inherit vectorcraft;
      };
    };
}
