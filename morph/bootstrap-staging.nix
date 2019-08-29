# This is a customized configuration that can be edited slightly and then
# dropped on a 100TB machine that is being crossgraded to NixOS.
{ config, pkgs, ... }:
let
  # Make all these correct.
  interface = "eno1";
  publicIPv4 = "69.36.183.24";
  prefixLength = 24;
  gateway = "69.36.183.1";
  gatewayInterface = "eno1";
  grubDeviceID = "wwn-0x5000c500936410b9";
  rootPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN4GenAY/YLGuf1WoMXyyVa3S9i4JLQ0AG+pt7nvcLlQ exarkun@baryon";
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.loader.timeout = 1;
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/disk/by-id/${grubDeviceID}";

  # Let me in to do subsequent configuration.
  networking.firewall.enable = false;
  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    rootPublicKey
  ];

  # Provide the static network configuration.
  networking.dhcpcd.enable = false;
  networking.interfaces = {
    "${interface}".ipv4.addresses = [
      { address = publicIPv4; inherit prefixLength; }
    ];
  };
  networking.defaultGateway = {
    address = gateway;
    interface = gatewayInterface;
  };
  networking.nameservers = [
    "4.2.2.1"
    "8.8.8.8"
  ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?
}
