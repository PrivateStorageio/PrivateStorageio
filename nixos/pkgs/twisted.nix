{ twisted }:
twisted.overrideAttrs (old: {
  prePatch = old.patchPhase;
  patchPhase = null;
  # Add a patch which adds more logging to a namer resolver failure case.  The
  # NixOS system test harness might be setting up a weird semi-broken system
  # that provokes a weird behavior out of getaddrinfo() that Twisted doesn't
  # normally handle.  The logging can help with debugging this case.  We
  # should think about upstreaming something related to this.
  patches = (if old ? "patches" then old.patches else []) ++ [ ./twisted.patch ];
})
