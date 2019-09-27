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
    services.private-storage-issuer.issuer = lib.mkOption {
      default = "Ristretto";
      type = lib.types.str;
      example = lib.literalExample "Trivial";
      description = ''
        The issuer algorithm to use.  Either Trivial for a fake no-crypto
        algorithm or Ristretto for Ristretto-flavored PrivacyPass.
      '';
    };
    services.private-storage-issuer.ristrettoSigningKey = lib.mkOption {
      default = null;
      type = lib.types.str;
      description = ''
        The Ristretto signing key to use.  Required if the issuer is
        ``Ristretto``.
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
          ExecStart =
            let
              args =
                if cfg.issuer == "Trivial"
                  then "--issuer Trivial"
                  else "--issuer Ristretto --signing-key ${cfg.ristrettoSigningKey}";
            in
              "${cfg.package}/bin/PaymentServer-exe ${args}";
          Type = "simple";
          Restart = "always";
        };
      };
    };
}
