{ callPackage }:
let
  leasereport = import ./leasereport-repo.nix;

  # Pin a particular version of haskell.nix.  The particular version isn't
  # special.  It's just recent at the time this expression was written and it
  # is known to work with LeaseReport.  It could be bumped if necessary but
  # this would probably only happen as a result of bumping the resolver in
  # stack.yaml.
  haskellNixSrc = builtins.fetchTarball https://github.com/input-output-hk/haskell.nix/archive/31fd01e14729e686de0a915b9bc4ff70397a84c7.tar.gz;
in
  (callPackage "${leasereport}/nix" { inherit haskellNixSrc; }).LeaseReport.components.exes.LeaseReport
