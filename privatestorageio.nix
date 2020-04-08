{ stdenv, lib, graphviz, python3Packages }:
stdenv.mkDerivation rec {
  version = "0.0";
  name = "privatestorageio-${version}";
  src = lib.cleanSource ./.;

  depsBuildBuild = [
    graphviz
  ];

  buildPhase = ''
  ${python3Packages.sphinx}/bin/sphinx-build -W docs/source docs/build
  '';

  installPhase = ''
  mkdir $out
  mv docs/build $out/docs
  '';
}
