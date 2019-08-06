# A NixOS module which can instantiate a Tahoe-LAFS storage server in the
# preferred configuration for the Private Storage grid.
{ pkgs, lib, config, ... }:
let
  pspkgs = import pkgs.path
  { overlays = [ (import ./overlays.nix) ];
  };
  cfg = config.services.private-storage;
in
{

  # Upstream tahoe-lafs module conflicts with ours (since ours is a
  # copy/paste/edit of upstream's...).  Disable
  # it.
  #
  # https://nixos.org/nixos/manual/#sec-replace-modules
  disabledModules =
  [ "services/network-filesystems/tahoe.nix"
  ];

  # Load our tahoe-lafs module.
  imports =
  [ ./tahoe.nix
  ];

  options =
  { services.private-storage.enable = lib.mkEnableOption "private storage service";
    services.private-storage.tahoe.package = lib.mkOption
    { default = pspkgs.privatestorage;
      type = lib.types.package;
      example = lib.literalExample "pkgs.tahoelafs";
      description = ''
        The package to use for the Tahoe-LAFS daemon.
      '';
    };
  };
  config = lib.mkIf cfg.enable
  { services.tahoe.nodes."alpha" =
    { package = config.services.private-storage.tahoe.package;
      sections =
      { node =
        { nickname = "alpha";
        };
        storage =
        { enable = true;
        };
      };
    };
  };
}
