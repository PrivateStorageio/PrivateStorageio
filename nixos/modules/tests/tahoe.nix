{ ... }: {
  nodes = {
    storage = { config, pkgs, ... }: {
      imports = [
        ../tahoe.nix
      ];

      services.tahoe.nodes.storage = {
        package = (pkgs.callPackage ../pspkgs.nix { }).privatestorage;
        sections = {
          node = {
            nickname = "storage";
            "web.port" = "tcp:4000:interface=127.0.0.1";
            "tub.port" = "tcp:4001";
            "tub.location" = "tcp:127.0.0.1:4001";
          };
          storage = {
            enabled = true;
          };
        };
      };
    };
  };
  testScript = ''
  startAll;

  # After the service starts, destroy the "created" marker to force it to
  # re-create its internal state.
  $storage->waitForOpenPort(4001);
  $storage->succeed("systemctl stop tahoe.storage");
  $storage->succeed("rm /var/db/tahoe-lafs/storage.created");
  $storage->succeed("systemctl start tahoe.storage");

  # After it starts up again, verify it has consistent internal state and a
  # backup of the prior state.
  $storage->waitForOpenPort(4001);
  $storage->succeed("[ -e /var/db/tahoe-lafs/storage ]");
  $storage->succeed("[ -e /var/db/tahoe-lafs/storage.created ]");
  $storage->succeed("[ -e /var/db/tahoe-lafs/storage.1 ]");
  $storage->succeed("[ -e /var/db/tahoe-lafs/storage.1/private/node.privkey ]");
  $storage->succeed("[ -e /var/db/tahoe-lafs/storage.1/private/node.pem ]");
  $storage->succeed("[ ! -e /var/db/tahoe-lafs/storage.2 ]");

  # Stop it again, once again destroy the "created" marker, and this time also
  # jam some partial state in the way that will need cleanup.
  $storage->succeed("systemctl stop tahoe.storage");
  $storage->succeed("rm /var/db/tahoe-lafs/storage.created");
  $storage->succeed("mkdir -p /var/db/tahoe-lafs/storage.atomic/partial");
  eval {
    $storage->succeed("systemctl start tahoe.storage");
    1;
  } or do {
    my ($x, $y) = $storage->execute("journalctl -u tahoe.storage");
    $storage->log($y);
    die $@;
  };

  # After it starts up again, verify it has consistent internal state and
  # backups of the prior two states.  It also has no copy of the inconsistent
  # state because it could never have been used.
  $storage->waitForOpenPort(4001);
  $storage->succeed("[ -e /var/db/tahoe-lafs/storage ]");
  $storage->succeed("[ -e /var/db/tahoe-lafs/storage.created ]");
  $storage->succeed("[ -e /var/db/tahoe-lafs/storage.1 ]");
  $storage->succeed("[ -e /var/db/tahoe-lafs/storage.2 ]");
  $storage->succeed("[ -e /var/db/tahoe-lafs/storage.2/private/node.privkey ]");
  $storage->succeed("[ -e /var/db/tahoe-lafs/storage.2/private/node.pem ]");
  $storage->succeed("[ ! -e /var/db/tahoe-lafs/storage.atomic ]");
  $storage->succeed("[ ! -e /var/db/tahoe-lafs/storage/partial ]");
  $storage->succeed("[ ! -e /var/db/tahoe-lafs/storage.3 ]");
  '';
}
