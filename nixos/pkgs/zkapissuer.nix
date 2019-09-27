{ callPackage }:
let
  paymentServer = import ./zkapissuer-repo.nix;
in
  (callPackage "${paymentServer}/nix" { }).PaymentServer
