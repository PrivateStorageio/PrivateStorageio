# A NixOS module which configures a system that is hosted by 100TB.
{ pkgs, lib, config, ... }:
let
  cfg = config."100tb".config;
  options = {
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
    rootPublicKey = lib.mkOption
    { type = lib.types.str;
      example = lib.literalExample "ssh-ed25519 AAAA... username@host";
      description = "The public key to install for the root user.";
    };
  };
in {
  options =
  { "100tb".config = lib.mkOption
    { type = lib.types.submodule { inherit options; };
      description = "Host-specific configuration relevant to a 100TB system.";
    };
  };

  config =
  { boot.loader.grub.enable = true;
    boot.loader.grub.version = 2;
    boot.loader.grub.device = "/dev/disk/by-id/${cfg.grubDeviceID}";

    # Get a slightly faster boot time than default.  Maybe this could even be
    # 0 but I'm not sure.
    boot.loader.timeout = 1;

    # Let me in to do subsequent configuration.
    networking.firewall.enable = false;
    services.openssh.enable = true;

    users.users.root.openssh.authorizedKeys.keys = [
      cfg.rootPublicKey
    ];

    # Provide the static network configuration.
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
