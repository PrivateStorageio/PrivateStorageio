{ callPackage }:
let
  leasereport = import ./leasereport-repo.nix;
in
  (callPackage "${leasereport}/nix" { }).LeaseReport.components.exe.LeaseReport
