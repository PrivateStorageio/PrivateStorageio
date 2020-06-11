# Copy/pasted from nixos/modules/services/network-filesystems/tahoe.nix :/ We
# require control over additional configuration options compared to upstream
# and it's not clear how to do this without duplicating everything.
{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.tahoe;
  ini = pkgs.callPackage ../lib/ini.nix { };
in
  {
    options.services.tahoe = {
      introducers = mkOption {
        default = {};
        type = with types; attrsOf (submodule {
          options = {
            nickname = mkOption {
              type = types.str;
              description = ''
                The nickname of this Tahoe introducer.
              '';
            };
            tub.port = mkOption {
              default = 3458;
              type = types.int;
              description = ''
                The port on which the introducer will listen.
              '';
            };
            tub.location = mkOption {
              default = null;
              type = types.nullOr types.str;
              description = ''
                The external location that the introducer should listen on.

                If specified, the port should be included.
              '';
            };
            package = mkOption {
              default = pkgs.tahoelafs;
              defaultText = "pkgs.tahoelafs";
              type = types.package;
              example = literalExample "pkgs.tahoelafs";
              description = ''
                The package to use for the Tahoe LAFS daemon.
              '';
            };
          };
        });
        description = ''
          The Tahoe introducers.
        '';
      };
      nodes = mkOption {
        default = {};
        type = with types; attrsOf (submodule {
          options = {
            sections = mkOption {
              type = types.attrs;
              description = ''
                Top-level configuration sections.
              '';
              default = {
                "node" = { };
                "client" = { };
                "storage" = { };
              };
            };
            package = mkOption {
              default = pkgs.tahoelafs;
              defaultText = "pkgs.tahoelafs";
              type = types.package;
              example = literalExample "pkgs.tahoelafs";
              description = ''
                The package to use for the Tahoe LAFS daemon.
              '';
            };
          };
        });
        description = ''
          The Tahoe nodes.
        '';
      };
    };
    config = mkMerge [
      (mkIf (cfg.introducers != {}) {
        environment = {
          etc = flip mapAttrs' cfg.introducers (node: settings:
            nameValuePair "tahoe-lafs/introducer-${node}.cfg" {
              mode = "0444";
              text = ''
                # This configuration is generated by Nix. Edit at your own
                # peril; here be dragons.

                [node]
                nickname = ${settings.nickname}
                tub.port = ${toString settings.tub.port}
                ${optionalString (settings.tub.location != null)
                  "tub.location = ${settings.tub.location}"}
              '';
            });
          # Actually require Tahoe, so that we will have it installed.
          systemPackages = flip mapAttrsToList cfg.introducers (node: settings:
            settings.package
          );
        };
        # Open up the firewall.
        # networking.firewall.allowedTCPPorts = flip mapAttrsToList cfg.introducers
        #   (node: settings: settings.tub.port);
        systemd.services = flip mapAttrs' cfg.introducers (node: settings:
          let
            pidfile = "/run/tahoe.introducer-${node}.pid";
            # This is a directory, but it has no trailing slash. Tahoe commands
            # get antsy when there's a trailing slash.
            nodedir = "/var/db/tahoe-lafs/introducer-${node}";
          in nameValuePair "tahoe.introducer-${node}" {
            description = "Tahoe LAFS node ${node}";
            wantedBy = [ "multi-user.target" ];
            path = [ settings.package ];
            restartTriggers = [
              config.environment.etc."tahoe-lafs/introducer-${node}.cfg".source ];
            serviceConfig = {
              Type = "simple";
              PIDFile = pidfile;
              # Believe it or not, Tahoe is very brittle about the order of
              # arguments to $(tahoe run). The node directory must come first,
              # and arguments which alter Twisted's behavior come afterwards.
              ExecStart = ''
                ${settings.package}/bin/tahoe run ${lib.escapeShellArg nodedir} -n -l- --pidfile=${lib.escapeShellArg pidfile}
              '';
            };
            preStart = ''
              if [ ! -d ${lib.escapeShellArg nodedir} ]; then
                mkdir -p /var/db/tahoe-lafs
                tahoe create-introducer ${lib.escapeShellArg nodedir}
              fi

              # Tahoe has created a predefined tahoe.cfg which we must now
              # scribble over.
              # XXX I thought that a symlink would work here, but it doesn't, so
              # we must do this on every prestart. Fixes welcome.
              # rm ${nodedir}/tahoe.cfg
              # ln -s /etc/tahoe-lafs/introducer-${node}.cfg ${nodedir}/tahoe.cfg
              cp /etc/tahoe-lafs/introducer-"${node}".cfg ${lib.escapeShellArg nodedir}/tahoe.cfg
            '';
          });
        users.users = flip mapAttrs' cfg.introducers (node: _:
          nameValuePair "tahoe.introducer-${node}" {
            description = "Tahoe node user for introducer ${node}";
            isSystemUser = true;
          });
      })
      (mkIf (cfg.nodes != {}) {
        environment = {
          etc = flip mapAttrs' cfg.nodes (node: settings:
            nameValuePair "tahoe-lafs/${node}.cfg" {
              mode = "0444";
              text = ''
                # This configuration is generated by Nix. Edit at your own
                # peril; here be dragons.

                ${ini.allConfigSectionsText settings.sections}
                '';
            });
          # Actually require Tahoe, so that we will have it installed.
          systemPackages = flip mapAttrsToList cfg.nodes (node: settings:
            settings.package
          );
        };
        # Open up the firewall.
        # networking.firewall.allowedTCPPorts = flip mapAttrsToList cfg.nodes
        #   (node: settings: settings.tub.port);
        systemd.services = flip mapAttrs' cfg.nodes (node: settings:
          let
            pidfile = "/run/tahoe.${lib.escapeShellArg node}.pid";
            # This is a directory, but it has no trailing slash. Tahoe commands
            # get antsy when there's a trailing slash.
            nodedir = "/var/db/tahoe-lafs/${lib.escapeShellArg node}";
          in nameValuePair "tahoe.${node}" {
            description = "Tahoe LAFS node ${node}";
            wantedBy = [ "multi-user.target" ];
            path = [ settings.package ];
            restartTriggers = [
              config.environment.etc."tahoe-lafs/${node}.cfg".source ];
            serviceConfig = {
              Type = "simple";
              PIDFile = pidfile;
              # Believe it or not, Tahoe is very brittle about the order of
              # arguments to $(tahoe run). The node directory must come first,
              # and arguments which alter Twisted's behavior come afterwards.
              ExecStart = ''
                ${settings.package}/bin/tahoe run ${nodedir} -n -l- --pidfile=${pidfile}
              '';
            };
            preStart =
            let
              created = "${nodedir}.created";
              atomic = "${nodedir}.atomic";
            in ''
              if [ ! -e ${created} ]; then
                mkdir -p /var/db/tahoe-lafs/

                # Get rid of any prior partial efforts.  It might not exist.
                # Don't let this tank us.
                rm -rv ${atomic} && [ ! -e ${atomic} ]

                # Really create the node.
                tahoe create-node --hostname=localhost ${atomic}

                # Move it to the real location.  We don't create it in-place
                # because we might fail partway through and leave inconsistent
                # state.  Also, systemd probably created logs/incidents/ already and
                # `create-node` complains if it finds these exist already.
                rm -rv ${nodedir} && [ ! -e ${nodedir} ]
                mv ${atomic} ${nodedir}
                touch ${created}
              fi

              # Tahoe has created a predefined tahoe.cfg which we must now
              # scribble over.
              # XXX I thought that a symlink would work here, but it doesn't, so
              # we must do this on every prestart. Fixes welcome.
              # rm ${nodedir}/tahoe.cfg
              # ln -s /etc/tahoe-lafs/${lib.escapeShellArg node}.cfg ${nodedir}/tahoe.cfg
              cp /etc/tahoe-lafs/${lib.escapeShellArg node}.cfg ${nodedir}/tahoe.cfg
            '';
          });
        users.users = flip mapAttrs' cfg.nodes (node: _:
          nameValuePair "tahoe.${node}" {
            description = "Tahoe node user for node ${node}";
            isSystemUser = true;
          });
      })
    ];
  }
