let
  pkgs = import <nixpkgs> { };
  pspkgs = import ../pspkgs.nix { inherit pkgs; };

  # Separate helper programs so we can write as little perl inside a string
  # inside a nix expression as possible.
  run-introducer = ./run-introducer.py;
  run-client = ./run-client.py;
  get-passes = ./get-passes.py;
  exercise-storage = ./exercise-storage.py;

  # The root URL of the Ristretto-flavored PrivacyPass issuer API.
  issuerURL = "http://issuer:8081/";

  # The issuer's signing key.  Notionally, this is a secret key.  This is only
  # the value for this system test though so I don't care if it leaks to the
  # world at large.
  ristrettoSigningKey = "wumQAfSsJlQKDDSaFN/PZ3EbgBit8roVgfzllfCK2gQ=";

  # Here are the preconstructed secrets which we can assign to the introducer.
  # This is a lot easier than having the introducer generate them and then
  # discovering and configuring the other nodes with them.
  pemFile = ./node.pem;

  tubID = "rr7y46ixsg6qmck4jkkc7hke6xe4sv5f";
  swissnum = "2k6p3wrabat5jrj7otcih4cjdema4q3m";
  introducerPort = 35151;
  location = "tcp:introducer:${toString introducerPort}";
  introducerFURL = "pb://${tubID}@${location}/${swissnum}";
  introducerFURLFile = pkgs.writeTextFile {
    name = "introducer.furl";
    text = introducerFURL;
  };
  networkConfig = {
    # Just need to disable the firewall so all the traffic flows freely.  We
    # could do other network configuration here too, if we wanted.  Initially
    # I thought we might need to statically asssign IPs but we can just use
    # the node names, "introducer", etc, instead.
    networking.firewall.enable = false;
    networking.dhcpcd.enable = false;
  };
in
# https://nixos.org/nixos/manual/index.html#sec-nixos-tests
import <nixpkgs/nixos/tests/make-test.nix> {

  nodes = rec {
    # Get a machine where we can run a Tahoe-LAFS client node.
    client =
      { config, pkgs, ... }:
      { environment.systemPackages = [
          pkgs.daemonize
          # A Tahoe-LAFS configuration capable of using the right storage
          # plugin.
          pspkgs.privatestorage
          # Support for the tests we'll run.
          (pkgs.python3.withPackages (ps: [ ps.requests ]))
        ];
      } // networkConfig;

    # Get another machine where we can run a Tahoe-LAFS introducer node.  It has the same configuration as the client.
    introducer = client;

    # Configure a single machine as a PrivateStorage storage node.
    storage =
      { config, pkgs, ... }:
      { imports =
        [ ../private-storage.nix
        ];
        services.private-storage.enable = true;
        services.private-storage.publicIPv4 = "storage";
        services.private-storage.introducerFURL = introducerFURL;
        services.private-storage.issuerRootURL = issuerURL;
        services.private-storage.ristrettoSigningKeyPath = pkgs.writeText "signing-key.private" ristrettoSigningKey;
      } // networkConfig;

    # Operate an issuer as well.
    issuer =
    { config, pkgs, ... }:
    { imports =
      [ ../issuer.nix
      ];
      services.private-storage-issuer = {
        enable = true;
        issuer = "Ristretto";
        inherit ristrettoSigningKey;
      };
    } // networkConfig;
  };

  # Test the machines with a Perl program (sobbing).
  testScript =
    ''
      # Start booting all the VMs in parallel to speed up operations down below.
      startAll;

      # Set up a Tahoe-LAFS introducer.
      $introducer->copyFileFromHost(
          '${pemFile}',
          '/tmp/node.pem'
      );

      eval {
        $introducer->succeed(
          'set -eo pipefail; ' .
          '${run-introducer} /tmp/node.pem ${toString introducerPort} ${introducerFURL} | ' .
          'systemd-cat'
        );
        # Signal success. :/
        1;
      } or do {
        my $error = $@ || 'Unknown failure';
        my ($code, $log) = $introducer->execute('cat /tmp/stdout /tmp/stderr');
        $introducer->log($log);
        die $@;
      };

      #
      # Get a Tahoe-LAFS storage server up.
      #
      my ($code, $version) = $storage->execute('tahoe --version');
      $storage->log($version);

      # The systemd unit should reach the running state.
      $storage->waitForUnit('tahoe.storage.service');

      # Some while after that the Tahoe-LAFS node should listen on the web API
      # port. The port number here has to agree with the port number set in
      # the private-storage.nix module.
      $storage->waitForOpenPort(3456);

      # Once the web API is listening it should be possible to scrape some
      # status from the node if it is really working.
      $storage->succeed('tahoe -d /var/db/tahoe-lafs/storage status');

      #
      # Storage appears to be working so try to get a client to speak with it.
      #
      $client->succeed('set -eo pipefail; ${run-client} ${introducerFURL} ${issuerURL} | systemd-cat');
      $client->waitForOpenPort(3456);

      # Get some ZKAPs from the issuer.
      eval {
        $client->succeed('set -eo pipefail; ${get-passes} http://127.0.0.1:3456 http://issuer:8081 | systemd-cat');
        # succeed() is not success but 1 is.
        1;
      } or do {
        my $error = $@ || 'Unknown failure';
        my ($code, $log) = $client->execute('cat /tmp/stdout /tmp/stderr');
        $client->log($log);
        die $@;
      };

      # The client should be prepped now.  Make it try to use some storage.
      eval {
        $client->succeed('set -eo pipefail; ${exercise-storage} /tmp/client | systemd-cat');
        # nothing succeeds like ... 1.
        1;
      } or do {
        my $error = $@ || 'Unknown failure';
        my ($code, $log) = $client->execute('cat /tmp/stdout /tmp/stderr');
        $client->log($log);
        die $@;
      };
      '';
}
