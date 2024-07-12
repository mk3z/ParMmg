{
  description = "ParMmg";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    mmg = {
      url = "github:mk3z/mmg/develop";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        mmg = inputs.mmg.packages.${system}.default;
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          name = "parmmg";

          src = ./.;

          nativeBuildInputs = with pkgs; [
            cmake
            gfortran
            perl
          ];

          buildInputs = with pkgs;
            [
              mpi
              metis
            ]
            ++ [mmg];

          preConfigure = ''
            patchShebangs ./
          '';

          cmakeFlags = [
            "-DBUILD_SHARED_LIBS:BOOL=TRUE"
            "-DDOWNLOAD_MMG=OFF"
            "-DDOWNLOAD_METIS=OFF"
            "-Wno-dev"
          ];
        };
      }
    );
}
