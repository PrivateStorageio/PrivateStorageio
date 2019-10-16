# Pin the deployment package-set to a specific version of nixpkgs.  This is
# NixOS 19.09 as of Oct 2 2019.  There's nothing special about it.  It's just
# recent at the time of development.  It can be upgraded when there is value
# in doing so.  Meanwhile, our platform doesn't shift around beneath us in
# surprising ways as time passes.
import (builtins.fetchTarball {
  url = "https://github.com/NixOS/nixpkgs-channels/archive/5d5cd70516001e79516d2ade8bcf31df208a4ef3.tar.gz";
  sha256 = "042i081cfwdvcfp3q79219akypb53chf730wg0vwxlp21pzgns33";
})
