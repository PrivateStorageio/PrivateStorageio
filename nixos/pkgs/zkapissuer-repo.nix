let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "PrivateStorageio";
    repo = "PaymentServer";
    rev = "3040a41f70d509e62a6d42f649bbe7b56f97d004";
    sha256 = "1i4z7gqyrv21p6v99aaf1vk849n47c30ffs5y3nmmrb2pv3gx6iv";
  }