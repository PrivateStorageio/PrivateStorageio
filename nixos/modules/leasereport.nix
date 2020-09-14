{ callPackage }:
let
  leasereport = import ./leasereport-repo.nix;

  # Pin a particular version of haskell.nix.  The particular version isn't
  # special.  It's just recent at the time this expression was written and it
  # is known to work with LeaseReport.  It could be bumped if necessary but
  # this would probably only happen as a result of bumping the resolver in
  # stack.yaml.
  haskellNixSrc = builtins.fetchTarball https://github.com/input-output-hk/haskell.nix/archive/f6663a8449f5e4a7393aa24601600c8f6e352c97.tar.gz;
in
  (callPackage "${leasereport}/nix" { inherit haskellNixSrc; }).LeaseReport.components.exes.LeaseReport
