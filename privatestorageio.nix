{ stdenv, python3Packages }:
stdenv.mkDerivation rec {
  version = "0.0";
  name = "privatestorageio-${version}";
  src = ./.;
  depsBuildBuild = [
    python3Packages.sphinx
  ];
}
