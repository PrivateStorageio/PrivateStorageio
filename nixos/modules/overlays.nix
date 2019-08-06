self: super: {
  python27 = super.python27.override {
    packageOverrides = python-self: python-super: {
      # Get the newest Tahoe-LAFS as a module instead of an application.
      tahoe-lafs = python-super.toPythonModule (python-super.callPackage ../pkgs/tahoe-lafs.nix { });

      # Get our ZKAP authorizer plugin package.
      zkapauthorizer = python-self.callPackage ../pkgs/zkapauthorizer.nix { };

      # new tahoe-lafs has a new dependency on eliot.
      eliot = python-super.callPackage ../pkgs/eliot.nix { };

      # new tahoe-lafs depends on a very recent autobahn for better websocket
      # testing features.
      autobahn = python-super.callPackage ../pkgs/autobahn.nix { };

      # new autobahn requires a newer cryptography
      cryptography = python-super.callPackage ../pkgs/cryptography.nix { };

      # new cryptography requires a newer cryptography_vectors
      cryptography_vectors = python-super.callPackage ../pkgs/cryptography_vectors.nix { };

      # upstream twisted package is missing a recently added dependency.
      twisted = python-super.twisted.overrideAttrs (old:
      { propagatedBuildInputs = old.propagatedBuildInputs ++ [ python-super.appdirs ];
        checkPhase = ''
          ${self.python.interpreter} -m twisted.trial twisted
        '';
      });

    };
  };

  privatestorage = self.python27.buildEnv.override
  { extraLibs =
    [ self.python27Packages.tahoe-lafs
      self.python27Packages.zkapauthorizer
    ];
    # Twisted's dropin.cache always collides between different
    # plugin-providing packages.
    ignoreCollisions = true;
  };
}
