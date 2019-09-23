let
  pkgs = import <nixpkgs> { };
  # Here are the preconstructed secrets which we can assign to the introducer.
  # This is a lot easier than having the introducer generate them and then
  # discovering and configuring the other nodes with them.
  pemFile = pkgs.writeTextFile {
    name = "node.pem";
    text = ''
-----BEGIN CERTIFICATE-----
MIICojCCAYoCAQEwDQYJKoZIhvcNAQELBQAwFzEVMBMGA1UEAwwMbmV3cGJfdGhp
bmd5MB4XDTE5MDkyMDE4NDkzNloXDTIwMDkxOTE4NDkzNlowFzEVMBMGA1UEAwwM
bmV3cGJfdGhpbmd5MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1zK4
wH0ZvjFCnFo+PvT/ANBJ2H7pZQDRHFHmhW28VeQ4nCqlifjxJ/MOWpqKYK6rxHOK
DNTDR5MbkFO7l0yquB0/FArP9RErezKakXz8qSLhipDZk7y+0fKWMPxcgdSzm28Z
817Yzp1naXPHQRcno3M3eo58FyoTDAOXP3hiS+bFm8RGVINLSBJtILKoplvgSdyD
/1Xg4zbh2FK+gS0f92jel5JyAaebt3EQPiIxwUrvi5a1w5EQKi13sJ22RK5H6sch
Xg76GMMBCckLs+g8xza5uHLbotMnWb7ddW+pC0SQsrihUxz902lQoUuxq2aJig6o
Ti6wsetUcxtOErfy6wIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQC7ciESyktDoAus
ni6zW30AXnoTxD/LNCf2HMUFcyFF57p5dcaTsAUhUd+aKX/iJyhy6bfgo8GGI5xN
LvhvNQ6Cb6Z9qiCWDvEll+nbfuJNEanEd6bkR06/TX5bK5iDMYZD4Z+SSHsNDNEF
DXJ96zp42UfQTdimxXHmZidAYvtYeLe4EDoJGhpuryEAIUwPdTvsPX+pLfCdtdyP
595zbHkUPPnA3feWckcmN0FWiXisaE4ERXdPrcBnMB5TqY7KI0j2TjW59l1TnNFD
dEKMyBD89ndBXvZq8JO8nzdM0WF32jSM/Yb+clS6PHoypHGo4jBTE3AEIXMUe//x
MSwj51gz
-----END CERTIFICATE-----
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDXMrjAfRm+MUKc
Wj4+9P8A0EnYfullANEcUeaFbbxV5DicKqWJ+PEn8w5amopgrqvEc4oM1MNHkxuQ
U7uXTKq4HT8UCs/1ESt7MpqRfPypIuGKkNmTvL7R8pYw/FyB1LObbxnzXtjOnWdp
c8dBFyejczd6jnwXKhMMA5c/eGJL5sWbxEZUg0tIEm0gsqimW+BJ3IP/VeDjNuHY
Ur6BLR/3aN6XknIBp5u3cRA+IjHBSu+LlrXDkRAqLXewnbZErkfqxyFeDvoYwwEJ
yQuz6DzHNrm4ctui0ydZvt11b6kLRJCyuKFTHP3TaVChS7GrZomKDqhOLrCx61Rz
G04St/LrAgMBAAECggEAfRKjwmxzK9Fhj5H7n4exNf3ZDZUlfWiuILGRM3eGAL22
ET3QHJKtRrTDYPF0/6BFgNZOJAr8vHrJiGbCHruWdY+5+6IVH7As/1t37psgFgWJ
5Ikvi+glV8yQckQaV/MRuIMoKAS2Kc/eLLH32uLkTOFIG1j40lXH4DGuFFuZddbH
Ie2TsgUmI3LXTSGSq4qSgXyB46uGuGOn4WKIAKp7O4kN2jBB5y3q9C2YltQ+Dv+k
T64wBNK3ZnHHNKli0A86kzPLVQJfHgjzC76QRlC+guKgRoV9Kut3LLfoi6ep5yJr
RT6Pr/hTNKCluIZUTPhmB0u3xGr9gj6vDsMCanvrsQKBgQD5y7ZJqFvgh9MlhSLN
20p7jlyu+cYSDWktUjA4109ior8oaCVUXziSuPsr9JfwYRaYsJTUpCYKECFYLibA
qI+Jj/auJljuCmrfWuS9Z08sAmVoU+O4FZt2UVbui5l5spU41Ze09f81DpzkHhZ0
SEVH2SgChdy7KdPPhxcVhJHqJQKBgQDciwameP0WaazTY77ZRE4Yt+dPyPFkpSer
bibeMmss5d+QVo4B4YEL20CrmaJq+FB9u99nL1d6VsvtWuovvHKMmoM//D8Si7PW
ieAm9mN0L+2Xf25UVFBewQkzNuJJG+z1OtHFfIDDGnNzL2yx//3YFJnR/ehftsK7
lIlXUElzzwKBgGUW1cx1P8lb7k0u1ejtJ/VcpZGCL3A60SewLSezqsLGDgoyK3k7
l8944Nzm/V4gTF66h2COlX5ZDMV819372SrYggH0LuUWfi2pwQwNdPLgfV19JZjn
1aRKQp4DDLc9WDpJ5j0rmH5GTaPbsUaZwL/U1+Y9ehicUsWXa/YfUlWpAoGBAJCZ
7yBTj82UOCbZ7ZZS/MmkOtvLKssMpnf2XzGs6SylA/KFbdK54ny9oydgMmfkrBHk
jtP+7GJgapET3RyzeH/MB2Z6o3grdRyjhf7F6euSSTvd558PMSsPclLMF45L6w/X
IxdTTLGftDa/z4reB7gXucs/qY6oLAIFoA9Jqv9tAoGAIpw4GDw5IQFZhcHuHCOZ
Xrq9L1fR5rYBQa6xcPHkMbWzigcNJz7FnLg0tB1SvF23egpmj5VAcnWyjyj883pn
h2wuwJUFy8LALtjJwqhjUtQfv5LLiT5061/CUrhD3GEBNlYbOO4FA1Z0SIhFYn40
VzowmHAqdxYvlfJsWe91UI0=
-----END PRIVATE KEY-----
'';
  };
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
