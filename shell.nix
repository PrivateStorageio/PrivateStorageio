let
  nixpkgs-rev = builtins.readFile ./nixpkgs.rev;
  nixpkgs-url = "https://github.com/NixOS/nixpkgs-channels/archive/${nixpkgs-rev}.tar.gz";
  nixpkgs-src = builtins.fetchTarball {
    url = nixpkgs-url;
    sha256 = "sha256:0bv34yz892yxhx2kb8a1yr5pm0g8ck5w021yj87r7kfnp416apdh";
  };
  nixpkgs = import nixpkgs-src { };
in
{ pkgs ? nixpkgs }:
let
  # Get a version of Morph known to work with our version of NixOS.
  morph-src = pkgs.fetchFromGitHub {
    owner = "DBCDK";
    repo = "morph";
    rev = "3856a9c2f733192dee1600b8655715d760ba1803";
    hash = "sha256:0jhypvj45yjg4cn4rvb2j9091pl6z5j541vcfaln5sb3ds14fkwf";
  };
  morph = pkgs.callPackage (morph-src + "/nix-packaging") { };
in
pkgs.mkShell {
  NIX_PATH = "nixpkgs=${nixpkgs-src}";
  buildInputs = [
    morph
  ];
}
