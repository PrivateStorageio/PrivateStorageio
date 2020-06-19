let
  pkgs = import <nixpkgs> { };
  pspkgs = import ../pspkgs.nix { inherit pkgs; };

  sshPrivateKey = ./probeuser_ed25519;
  sshPublicKey = ./probeuser_ed25519.pub;
  sshUsers = {
    root = (builtins.readFile sshPublicKey);
    probeuser = (builtins.readFile sshPublicKey);
  };
  # Generate a command which can be used with runOnNode to ssh to the given
  # host.
  ssh = username: hostname: [
    "cp" sshPrivateKey "/tmp/ssh_key" ";"
    "chmod" "0400" "/tmp/ssh_key" ";"
    "ssh" "-oStrictHostKeyChecking=no" "-i" "/tmp/ssh_key" "${username}@${hostname}" ":"
  ];

  # Separate helper programs so we can write as little perl inside a string
  # inside a nix expression as possible.
  run-introducer = ./run-introducer.py;
  run-client = ./run-client.py;
  get-passes = ./get-passes.py;
  exercise-storage = ./exercise-storage.py;

  # This is a test double of the Stripe API server.  It is extremely simple.
  # It barely knows how to respond to exactly the API endpoints we use,
  # exactly how we use them.
  stripe-api-double = ./stripe-api-double.py;

  # The root URL of the Ristretto-flavored PrivacyPass issuer API.
  issuerURL = "http://issuer/";

  voucher = "xyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxy";

  # The issuer's signing key.  Notionally, this is a secret key.  This is only
  # the value for this system test though so I don't care if it leaks to the
  # world at large.
  ristrettoSigningKeyPath =
    let
      key = "wumQAfSsJlQKDDSaFN/PZ3EbgBit8roVgfzllfCK2gQ=";
      basename = "signing-key.private";
    in
      pkgs.writeText basename key;

  stripeSecretKeyPath =
    let
      # Ugh.
      key = "sk_test_blubblub";
      basename = "stripe.secret";
    in
      pkgs.writeText basename key;

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

  # Return a Perl program fragment to run a shell command on one of the nodes.
  # The first argument is the name of the node.  The second is a list of the
  # argv to run.
  #
  # The program's output is piped to systemd-cat and the Perl fragment
  # evaluates to success if the command exits with a success status.
  runOnNode = node: argv:
    let
      command = builtins.concatStringsSep " " argv;
    in
      "
      \$${node}->succeed('set -eo pipefail; ${command} | systemd-cat');
      # succeed() is not success but 1 is.
      1;
      ";
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
          (pkgs.python3.withPackages (ps: [ ps.requests ps.hyperlink ]))
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
        services.private-storage = {
          enable = true;
          publicIPv4 = "storage";
          introducerFURL = introducerFURL;
          issuerRootURL = issuerURL;
          inherit ristrettoSigningKeyPath;
          inherit sshUsers;

        };
      } // networkConfig;

    # Operate an issuer as well.
    issuer =
    { config, pkgs, ... }:
    { imports =
      [ ../issuer.nix
      ];
      services.private-storage.sshUsers = sshUsers;

      services.private-storage-issuer = {
        enable = true;
        domain = "issuer";
        tls = false;
        issuer = "Ristretto";
        inherit ristrettoSigningKeyPath;
        letsEncryptAdminEmail = "user@example.invalid";
        allowedChargeOrigins = [ "http://unused.invalid" ];

        inherit stripeSecretKeyPath;
        stripeEndpointDomain = "api_stripe_com";
        stripeEndpointScheme = "HTTP";
        stripeEndpointPort = 80;
      };
    } // networkConfig;

    # Also run a fake Stripe API endpoint server.  Nodes in these tests run on
    # a network without outside access so we can't easily use the real Stripe
    # API endpoint and with this one we have greater control over the
    # behavior, anyway, without all of the unintentional transient network
    # errors that come from the public internet.  These tests *aren't* meant
    # to prove PaymentServer correctly interacts with the real Stripe API
    # server so this is an unverified fake.  The PaymentServer test suite
    # needs to take care of any actual Stripe API integration testing.
    "api_stripe_com" =
    { config, pkgs, ... }:
      let python = pkgs.python3.withPackages (ps: [ ps.twisted ]);
      in networkConfig // {
        environment.systemPackages = [
          python
          pkgs.curl
        ];

        systemd.services."api.stripe.com" = {
          enable = true;
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];
          script = "${python}/bin/python ${stripe-api-double} tcp:80";
        };
      };
  };

  # Test the machines with a Perl program (sobbing).
  testScript =
    ''
      # Start booting all the VMs in parallel to speed up operations down below.
      startAll;

      # The issuer and the storage server should accept SSH connections.  This
      # doesn't prove it is so but if it fails it's a pretty good indication
      # it isn't so.
      $storage->waitForOpenPort(22);
      ${runOnNode "issuer" (ssh "probeuser" "storage")}
      ${runOnNode "issuer" (ssh "root" "storage")}
      $issuer->waitForOpenPort(22);
      ${runOnNode "storage" (ssh "probeuser" "issuer")}
      ${runOnNode "storage" (ssh "root" "issuer")}

      # Set up a Tahoe-LAFS introducer.
      $introducer->copyFileFromHost(
          '${pemFile}',
          '/tmp/node.pem'
      );

      eval {
      ${runOnNode "introducer" [ run-introducer "/tmp/node.pem" (toString introducerPort) introducerFURL ]}
      } or do {
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
      ${runOnNode "client"  [ run-client introducerFURL issuerURL ]}
      $client->waitForOpenPort(3456);

      # Make sure the fake Stripe API server is ready for requests.
      eval {
        $api_stripe_com->waitForUnit("api.stripe.com");
        1;
      } or do {
        my ($code, $log) = $api_stripe_com->execute('journalctl -u api.stripe.com');
        $api_stripe_com->log($log);
        die $@;
      };

      # Get some ZKAPs from the issuer.
      eval {
        ${runOnNode "client" [ get-passes "http://127.0.0.1:3456" issuerURL voucher ]}
      } or do {
        my ($code, $log) = $client->execute('cat /tmp/stdout /tmp/stderr');
        $client->log($log);

        # Dump the fake Stripe API server logs, too, since the error may arise
        # from a PaymentServer/Stripe interaction.
        my ($code, $log) = $api_stripe_com->execute('journalctl -u api.stripe.com');
        $api_stripe_com->log($log);
        die $@;
      };

      # The client should be prepped now.  Make it try to use some storage.
      eval {
        ${runOnNode "client" [ exercise-storage "/tmp/client" ]}
      } or do {
        my ($code, $log) = $client->execute('cat /tmp/stdout /tmp/stderr');
        $client->log($log);
        die $@;
      };

      # It should be possible to restart the storage service without the
      # storage node fURL changing.
      eval {
        my $furlfile = '/var/db/tahoe-lafs/storage/private/storage-plugin.privatestorageio-zkapauthz-v1.furl';
        my $before = $storage->execute('cat ' . $furlfile);
        ${runOnNode "storage" [ "systemctl" "restart" "tahoe.storage" ]}
        my $after = $storage->execute('cat ' . $furlfile);
        if ($before != $after) {
          die 'fURL changes after storage node restart';
        }
        1;
      } or do {
        my ($code, $log) = $storage->execute('cat /tmp/stdout /tmp/stderr');
        $storage->log($log);
        die $@;
      };

      # The client should actually still work, too.
      eval {
        ${runOnNode "client" [ exercise-storage "/tmp/client" ]}
      } or do {
        my ($code, $log) = $client->execute('cat /tmp/stdout /tmp/stderr');
        $client->log($log);
        die $@;
      };
      ''; }
