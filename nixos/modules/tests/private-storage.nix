let
  pkgs = import <nixpkgs> { };
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

  # assignAddresses :: Set Name (Set -> AttrSet) -> Set Name (Set -> AttrSet)
  assignAddresses = nodes:
    let
      # makeNetwork :: Integer -> AttrSet
      makeNetwork = n: {
        networking.firewall.enable = false;
        networking.useDHCP = false;
        networking.interfaces.eth0.ipv4.addresses = [
          { address = "192.168.0.${toString n}"; prefixLength = 24; }
        ];
      };
      # addresses :: [Integer]
      addresses = pkgs.lib.range 0 (builtins.length (builtins.attrNames nodes));
      # nodesAsList :: [(Name, (Set -> AttrSet))]
      nodesAsList = pkgs.lib.attrsets.mapAttrsToList (name: value: [name value]) nodes;
      # nodeAndNetworkList :: [[Name, Set -> AttrSet], Integer]
      nodeAndNetworkList = pkgs.lib.lists.zipListsWith (fst: snd: [fst snd]) nodesAsList addresses;

      # mergeNodeAndNetwork :: Integer -> Name -> (Set -> AttrSet) -> {Name, (Set -> AttrSet)}
      mergeNodeAndNetwork = number: name: node: {
        inherit name;
        # Sadly we have to name arguments in this definition to get them
        # automatically passed in by the various autocall helpers in Nix.
        value = args@{ pkgs, ... }: ((node args) // (makeNetwork number));
      };
      at = builtins.elemAt;
      merged = map (elem:
        let
          node = (at (at elem 0) 1);
          name = (at (at elem 0) 0);
          number = (at elem 1);
        in
          mergeNodeAndNetwork number name node
      ) nodeAndNetworkList;
    in
      builtins.listToAttrs merged;
in
# https://nixos.org/nixos/manual/index.html#sec-nixos-tests
import <nixpkgs/nixos/tests/make-test.nix> {

  nodes = assignAddresses rec {
    # Get a machine where we can run a Tahoe-LAFS client node.
    client =
      { config, pkgs, ... }:
      { environment.systemPackages = [
          pkgs.tahoe-lafs
          pkgs.daemonize
        ];
      };

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
      };
  };

  # Test the machine with a Perl program (sobbing).
  testScript =
    ''
      # Start booting all the VMs in parallel to speed up operations down below.
      startAll;

      #
      # Set up a Tahoe-LAFS introducer.
      #
      $introducer->succeed(
          'tahoe create-introducer ' .
          '--port tcp:${toString introducerPort} ' .
          '--location tcp:introducer:${toString introducerPort} ' .
          '/tmp/introducer'
      );
      $introducer->copyFileFromHost(
          '${pemFile}',
          '/tmp/introducer/private/node.pem'
      );
      $introducer->copyFileFromHost(
          '${introducerFURLFile}',
          '/tmp/introducer/private/introducer.furl'
      );
      $introducer->succeed(
          'daemonize ' .
          '-e /tmp/stderr ' .
          '-o /tmp/stdout ' .
          '$(type -p tahoe) run /tmp/introducer'
      );

      eval {
        $introducer->waitForOpenPort(${toString introducerPort});
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

      # Create a Tahoe-LAFS client on it.
      $client->succeed(
          'tahoe create-client ' .
          '--shares-needed 1 ' .
          '--shares-happy 1 ' .
          '--shares-total 1 ' .
          '--introducer ${introducerFURL} /tmp/client'
      );

      # Launch it
      $client->succeed(
          'daemonize ' .
          '-e /tmp/stderr ' .
          '-o /tmp/stdout ' .
          '$(type -p tahoe) run /tmp/client'
      );
      $client->waitForOpenPort(3456);

      my ($code, $out) = $client->execute(
          'tahoe -d /tmp/client ' .
          'put /etc/issue'
      );
      ($code == 0) or do {
          my ($code, $log) = $client->execute('cat /tmp/stdout /tmp/stderr');
          $client->log($log);
          die "put failed";
      };
      $client->succeed(
          'tahoe -d /tmp/client ' .
          "get $out"
      );
    '';
}
