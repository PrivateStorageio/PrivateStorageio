# A NixOS module which can instantiate a Tahoe-LAFS storage server in the
# preferred configuration for the Private Storage grid.
{ pkgs, lib, config, ... }:
let
  pspkgs = pkgs.callPackage ./pspkgs.nix { };
  # Grab the configuration for this module for convenient access below.
  cfg = config.services.private-storage;
in
{
  # Upstream tahoe-lafs module conflicts with ours (since ours is a
  # copy/paste/edit of upstream's...).  Disable it.
  #
  # https://nixos.org/nixos/manual/#sec-replace-modules
  disabledModules =
  [ "services/network-filesystems/tahoe.nix"
  ];

  # Load our tahoe-lafs module.  It is configurable in the way I want it to be
  # configurable.
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
    services.private-storage.publicIPv4 = lib.mkOption
    { default = "127.0.0.1";
      type = lib.types.str;
      example = lib.literalExample "192.0.2.0";
      description = ''
        An IPv4 address to advertise for this storage service.
      '';
    };
    services.private-storage.introducerFURL = lib.mkOption
    { default = null;
      type = lib.types.nullOr lib.types.str;
      example = lib.literalExample "pb://<tubid>@<location hint>/<swissnum>";
      description = ''
        A Tahoe-LAFS introducer node fURL at which this storage node should announce itself.
      '';
    };
    services.private-storage.publicStoragePort = lib.mkOption
    { default = 8898;
      type = lib.types.int;
      example = lib.literalExample 8098;
      description = ''
        The port number on which to service storage clients.
      '';
    };
    services.private-storage.issuerRootURL = lib.mkOption
    { default = "https://issuer.privatestorage.io/";
      type = lib.types.str;
      example = lib.literalExample "https://example.invalid/";
      description = ''
        The URL of the Ristretto issuer service to announce.
      '';
    };
    services.private-storage.ristrettoSigningKeyPath = lib.mkOption
    { type = lib.types.path;
      example = lib.literalExample "/var/run/secrets/signing-key.private";
      description = ''
        The path to the Ristretto signing key for the service.
      '';
    };
  };

  # Define configuration based on values given for our options - starting with
  # the option that says whether this is even turned on.
  config = lib.mkIf cfg.enable
  { services.tahoe.nodes."storage" =
    { package = config.services.private-storage.tahoe.package;
      # Each attribute in this set corresponds to a section in the tahoe.cfg
      # file.  Attributes on those sets correspond to individual assignments
      # in those sections.
      #
      # We just populate this according to policy/preference of Private
      # Storage.
      sections =
      { client = if cfg.introducerFURL == null then {} else
        { "introducer.furl" = cfg.introducerFURL;
        };
        node =
        # XXX Should try to name that is unique across the grid.
        { nickname = "storage";
          # We have the web port active because the CLI uses it.  We may
          # eventually turn this off, or at least have it off by default (with
          # an option to turn it on).  I don't know how much we'll use the CLI
          # on the nodes.  Maybe very little?  Or maybe it will be part of a
          # health check for the node...  In any case, we tell it to bind to
          # localhost so no one *else* can use it.  And the principle of the
          # web interface is that merely having access to it doesn't grant
          # access to any data.  It does grant access to storage capabilities
          # but with our plugin configuration you still need ZKAPs to use
          # those...
          "web.port" = "tcp:3456:interface=127.0.0.1";
          # We have to tell Tahoe-LAFS where to listen for Foolscap
          # connections for the storage protocol.  We have to tell it twice.
          # First, in the syntax which it uses to listen.
          "tub.port" = "tcp:${toString cfg.publicStoragePort}";
          # Second, in the syntax it advertises to in the fURL.
          "tub.location" = "tcp:${cfg.publicIPv4}:${toString cfg.publicStoragePort}";
        };
        storage =
        { enabled = true;
          # Turn on our plugin.
          plugins = "privatestorageio-zkapauthz-v1";
        };
        "storageserver.plugins.privatestorageio-zkapauthz-v1" =
        { "ristretto-issuer-root-url" = cfg.issuerRootURL;
          "ristretto-signing-key-path" = cfg.ristrettoSigningKeyPath;
        };
      };
    };

    # Let traffic destined for the storage node's Foolscap server through.
    networking.firewall.allowedTCPPorts = [ cfg.publicStoragePort ];

  };
}
