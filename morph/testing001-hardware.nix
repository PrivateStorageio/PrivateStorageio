{
  imports = [ <nixpkgs/nixos/modules/virtualisation/amazon-image.nix> ];
  ec2.hvm = true;

  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "10000000";
}
