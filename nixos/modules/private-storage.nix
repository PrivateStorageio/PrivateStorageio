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
    services.private-storage.tahoe.node."tub.port" = lib.mkOption
    { default = "disabled";
      type = lib.types.str;
      example = lib.literalExample "tcp:8098";
      description = ''
        A value for the [node]tub.port in tahoe.cfg.
      '';
    };
    services.private-storage.tahoe.node."tub.location" = lib.mkOption
    { default = "disabled";
      type = lib.types.str;
      example = lib.literalExample "tcp:192.0.2.0:8098";
      description = ''
        A value for the [node]tub.location in tahoe.cfg.
      '';
    };
  };
  config = lib.mkIf cfg.enable
  { services.tahoe.nodes."storage" =
    { package = config.services.private-storage.tahoe.package;
      sections =
      { node =
        # XXX Should try to name that is unique across the grid.
        { nickname = "storage";
          "web.port" = "tcp:3456:interface=127.0.0.1";
          "tub.port" = cfg.tahoe.node."tub.port";
          "tub.location" = cfg.tahoe.node."tub.location";
        };
        storage =
        { enabled = true;
          plugins = "privatestorageio-zkapauthz-v1";
        };
        "storageserver.plugins.privatestorageio-zkapauthz-v1" =
        {
        };
      };
    };
  };
}
