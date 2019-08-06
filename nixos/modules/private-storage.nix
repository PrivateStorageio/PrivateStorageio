# A NixOS module which can instantiate a Tahoe-LAFS storage server in the
# preferred configuration for the Private Storage grid.
{ pkgs, lib, config, ... }:
let
  pspkgs = import pkgs.path
  { overlays = [ (import ./overlays.nix) ];
  };
  cfg = config.services.private-storage;
in
{ imports = [ ];
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
      nickname = "alpha";
      storage.enable = true;
    };
  };
}
