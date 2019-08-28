# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./staging001-hardware.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/disk/by-id/wwn-0x50000396cb7049cb";

  # Let me in to do subsequent configuration.
  networking.firewall.enable = false;
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN4GenAY/YLGuf1WoMXyyVa3S9i4JLQ0AG+pt7nvcLlQ exarkun@baryon"
  ];

  # networking.hostName = "staging001";
  # networking.domain = "storage.privatestorage-staging.com";

  # Provide the static network configuration.
  networking.interfaces = {
    enp2s0f0.ipv4.addresses = [
      { address = "209.95.51.251"; prefixLength = 24; }
    ];
  };
  networking.defaultGateway = {
      address = "209.95.51.1";
      interface = "enp2s0f0";
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?
}
