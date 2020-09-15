{ callPackage }:
let
  repo = import ./zkapauthorizer-repo.nix;
  typing = callPackage "${repo}/typing.nix" { };
  challenge-bypass-ristretto = callPackage "${repo}/python-challenge-bypass-ristretto.nix" { };
in
(callPackage "${repo}/zkapauthorizer.nix" {
    inherit challenge-bypass-ristretto;
    }).overrideAttrs (old: { doCheck = false; doInstallCheck = false; })
