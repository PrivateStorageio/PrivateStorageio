{ fetchFromGitHub, callPackage }:
let
  paymentServer = fetchFromGitHub {
    owner = "PrivateStorage";
    repo = "PaymentServer";
    rev = "6fbaac7a14d2a03b74e10a4a82b1147ee1dd7d49";
    sha256 = "0z8mqmns3fqbjy765830s5q6lhz3lxmslxahjc155jsv5b46gjip";
  };
in
  (callPackage "${paymentServer}/nix" { }).PaymentServer
