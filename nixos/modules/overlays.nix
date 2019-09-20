self: super: {
  privatestorage = super.python27.buildEnv.override
  { extraLibs =
    [ super.python27Packages.tahoe-lafs
      super.python27Packages.zkapauthorizer
    ];
    # Twisted's dropin.cache always collides between different
    # plugin-providing packages.
    ignoreCollisions = true;
  };
}
