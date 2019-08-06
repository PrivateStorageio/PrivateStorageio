{ pkgs, fetchFromGitHub, tahoe-lafs }:
let
  src = fetchFromGitHub
  { owner = "PrivateStorageio";
    repo = "ZKAPAuthorizer";
    rev = "a14b38f39e48d1560ea10ec26fffad6ce50fd00a";
    sha256 = "1v81l0ylx8r8xflhi16m8hb1dm3rlzyfrldiknvggqkyi5psdja4";
  };
in
pkgs.python27Packages.callPackage "${src}/zkapauthorizer.nix"
{ inherit tahoe-lafs;
}
