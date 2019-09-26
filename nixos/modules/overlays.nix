let
  pythonTwistedOverride = python-self: python-super: {
    twisted = python-super.callPackage ../pkgs/twisted.nix { inherit (python-super) twisted; };
  };
in
self: super: {
  privatestorage = self.python27.buildEnv.override
  { extraLibs =
    [ self.python27Packages.tahoe-lafs
      self.python27Packages.zkapauthorizer
    ];
    # Twisted's dropin.cache always collides between different
    # plugin-providing packages.
    # ignoreCollisions = true;
  };

  python27 = super.python27.override (old: {
    packageOverrides = super.lib.composeExtensions old.packageOverrides pythonTwistedOverride;
  });
}
