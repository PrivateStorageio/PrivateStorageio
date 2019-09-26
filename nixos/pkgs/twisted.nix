{ twisted }:
twisted.overrideAttrs (old: {
  version = old.version + "-0";
  prePatch = old.patchPhase;
  patchPhase = null;
  patches = (if old ? "patches" then old.patches else []) ++ [ ./twisted.patch ];
})
