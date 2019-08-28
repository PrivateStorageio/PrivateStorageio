{ publicIPv4, publicStoragePort }:
{ imports = [
    ./staging000-hardware.nix
    ../nixos/modules/private-storage.nix
  ];

  services.private-storage.enable = true;
  services.private-storage.tahoe.node."tub.port" = "tcp:${toString publicStoragePort}";
  services.private-storage.tahoe.node."tub.location" = "tcp:${publicIPv4}:${toString publicStoragePort}";

  networking.firewall.allowedTCPPorts = [ publicStoragePort ];
}
