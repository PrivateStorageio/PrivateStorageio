# A NixOS module which configures a system that is hosted by 100TB.  Each of
# our servers hosted with 100TB will probably import this module and pass it
# the minimum system configuration to get the server to boot and accept
# administrative ssh connections.
#
# A NixOS module is defined as a Nix expression language function.
{
  # This contains generally useful library functionality provided by nixpkgs.
  # These are things like string manipulation and, notably for us, a library
  # for defining options for configuring moduless.
  lib,

  # This is all of the configuration for a particular system where this module
  # might be instantiated.  For any system where we want the 100TB module to
  # be active, this should have the 100TB configuration details (IP, gateway,
  # etc).
  config,

  # More parameters exist and are accepted but we don't need them so we ignore them.
  ...
}:
let
  # Pull out the configuration for this module for convenient use later.  The
  # module name is quoted because `1` makes `100tb` look an awful lot like it
  # should be a number.
  cfg = config."100tb".config;

  # Define the API to this module.  Everything in `options` is about
  # specifying what kind of values we expect to be given.  This is both
  # human-facing documentation as well as guidance to NixOS about acceptable
  # values (mainly by type) so it can automatically reject certain bogus
  # values.  This value is in the `let` to make the code below a little easier
  # to read.  See below where we use it.
  options = {
    hostId = lib.mkOption
    { type = lib.types.str;
      example = lib.literalExample "abcdefab";
      description = "The 32-bit host ID of the machine, formatted as 8 hexadecimal characters.";
    };
    interface = lib.mkOption
    { type = lib.types.str;
      example = lib.literalExample "eno0";
      description = "The name of the network interface on which to configure a static address.";

    };
    publicIPv4 = lib.mkOption
    { type = lib.types.str;
      example = lib.literalExample "192.0.2.0";
      description = "The IPv4 address to statically assign to `interface`.";
    };
    prefixLength = lib.mkOption
    { type = lib.types.int;
      example = lib.literalExample 24;
      description = "The statically configured network's prefix length.";
    };
    gateway = lib.mkOption
    { type = lib.types.str;
      example = lib.literalExample "192.0.2.1";
      description = "The statically configured address of the network gateway.";
    };
    gatewayInterface = lib.mkOption
    { type = lib.types.str;
      example = lib.literalExample "eno0";
      description = "The name of the network interface for the default route.";
      default = cfg.interface;
    };
    grubDeviceID = lib.mkOption
    { type = lib.types.str;
      example = lib.literalExample "wwn-0x5000c500936410b9";
      description = "The ID of the disk on which to install grub.";
    };
  };
in {
  # Here we actually define the module's options.  They're what we said they
  # were above, all bundled up into a "submodule" which is really just a set
  # of options.
  options =
  { "100tb".config = lib.mkOption
    { type = lib.types.submodule { inherit options; };
      description = "Host-specific configuration relevant to a 100TB system.";
    };
  };

  # Now compute the configuration that results from whatever values were
  # supplied for our options.  A lot of this is currently very similar to
  # what's in bootstrap-configuration.nix (which is well commented).  The
  # similarity makes sense - both that configuration and this one need to get
  # a 100TB machine to boot and let an admin SSH in.
  #
  # Values that go into `config` here are merged into values that go into
  # `config` in any other active modules.  Basically, everything in this
  # `config` is treated as if it were in the configuration set defined by
  # `/etc/nixos/configuration.nix`.  The module just gives us a way to factor
  # separate concerns separately and make reuse easier.
  #
  # Note that this is not where Tahoe-LAFS configuration goes.  It's just
  # about getting base platform into good shape.
  #
  # Perhaps at some point this can be refactored to remove the duplication.
  # It's slightly tricky because we don't want to introduce any external
  # dependencies to bootstrap-configuration.nix because that would make it
  # harder to deploy in the bootstrap environment.
  config =
  { boot.loader.grub.enable = true;
    boot.loader.grub.version = 2;
    boot.loader.grub.device = "/dev/disk/by-id/${cfg.grubDeviceID}";

    boot.loader.timeout = 1;
    networking.firewall.enable = false;

    networking.hostId = cfg.hostId;
    networking.dhcpcd.enable = false;
    networking.interfaces = {
      "${cfg.interface}".ipv4.addresses = [
        { address = cfg.publicIPv4; inherit (cfg) prefixLength; }
      ];
    };
    networking.defaultGateway = {
      address = cfg.gateway;
      interface = cfg.gatewayInterface;
    };
    networking.nameservers = [
      "4.2.2.1"
      "8.8.8.8"
    ];
  };
}
