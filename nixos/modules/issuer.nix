# A NixOS module which can run a Ristretto-based issuer for PrivacyStorage
# ZKAPs.
{ lib, pkgs, config, ... }: let
  pspkgs = pkgs.callPackage ./pspkgs.nix { };
  zkapissuer = pspkgs.callPackage ../pkgs/zkapissuer.nix { };
in {
  options = {
    services.private-storage-issuer.enable = lib.mkEnableOption "PrivateStorage ZKAP Issuer Service";
    services.private-storage-issuer.package = lib.mkOption {
      default = zkapissuer.components.exes."PaymentServer-exe";
      type = lib.types.package;
      example = lib.literalExample "pkgs.zkapissuer";
      description = ''
        The package to use for the ZKAP issuer.
      '';
    };
  };

  config = let
    cfg = config.services.private-storage-issuer;
  in
    lib.mkIf cfg.enable {
      systemd.services.zkapissuer = {
        enable = true;
        description = "ZKAP Issuer";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];

        serviceConfig = {
          ExecStart = "${cfg.package}/bin/PaymentServer-exe";
          Type = "simple";
          Restart = "always";
        };
      };
    };
}
