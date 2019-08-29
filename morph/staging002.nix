{ config, pkgs, ... }:
{ imports =
    [ # Include the results of the hardware scan.
      ./staging002-hardware.nix
      # Configure it as a system operated by 100TB.
      # Instance details are read from <hostName>.config.json
      ../nixos/modules/100tb.nix
    ];

  "100tb".config = import ./staging002-config.nix;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?
}
