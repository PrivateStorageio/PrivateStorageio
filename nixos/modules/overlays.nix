let
  # Define a Python packageOverride that puts our version of some Python
  # packages into python27Packages.
  pythonPackageOverride = python-self: python-super: rec {
    # Get our Twisted derivation.  Pass in the old one so it can have pieces
    # overridden.  It needs to be passed in explicitly because callPackage is
    # specially crafted to always pull attributes from the fixed-point.  That
    # is, `python-self.callPackage` and `python-super.callPackage` will *both*
    # try to pass `python-self.twisted`.  So we take it upon ourselves to pass
    # the "correct" Twisted (it is correct because we call its override method
    # and that never converges if it is the fixed point Twisted).
    twisted = python-self.callPackage ../pkgs/twisted.nix {
      inherit (python-super) twisted;
    };

    # Put in our preferred version of tahoe-lafs as well.
    tahoe-lafs = python-self.callPackage ../pkgs/tahoe-lafs.nix { };

    # This is handy too...
    zkapauthorizer = python-self.callPackage ../pkgs/zkapauthorizer.nix {
      # And explicitly configure it with our preferred version of Tahoe-LAFS.
      inherit tahoe-lafs;
    };
  };
in
self: super: {
  leasereport = self.callPackage ./leasereport.nix { };

  # Use self.python27 to get the fixed point of all packages (that is, to
  # respect all of the overrides).  This is important since we want the
  # overridden Twisted as a dependency of this env, not the original one.
  #
  # This might seem to violate the advice to use super for "library
  # functionality" but python27.buildEnv should be considered a derivation
  # instead because it implies a whole mess of derivations (all of the Python
  # modules available).
  privatestorage = self.python27.buildEnv.override
  { # ... for dropin.cache
    ignoreCollisions = true;
    extraLibs =
    [ self.python27Packages.tahoe-lafs
      self.python27Packages.zkapauthorizer
    ];
  };

  # Using super.python27 here causes us to define a python27 that overrides
  # the value from the previously overlay, not from the fixed point.  This is
  # important because this override never converges.
  python27 = super.python27.override (old: {
    packageOverrides =
      if old ? packageOverrides then
        super.lib.composeExtensions old.packageOverrides pythonPackageOverride
      else
        pythonPackageOverride;
  });
}
