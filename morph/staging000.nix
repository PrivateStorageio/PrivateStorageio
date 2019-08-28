{ publicIPv4, publicStoragePort }:
{ imports = [
    ./staging000-hardware.nix
    ../nixos/modules/private-storage.nix
  ];

  services.private-storage =
  { enable = true;
    inherit publicIPv4;
    inherit publicStoragePort;
  };
}
