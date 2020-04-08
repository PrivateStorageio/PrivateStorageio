let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "PaymentServer";
    rev = "d6ad0042842ca0501c1e378b19bfdb42d5644223";
    sha256 = "018ybp83ljdwjn2kv1smkb5rx5h0hgw17a452bsyxdq61ysv4ajv";
  }