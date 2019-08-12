{ fetchFromGitHub, eliot, tahoelafs, plugins ? [ ] }:
tahoelafs.overrideAttrs (old:
{ src = fetchFromGitHub
  { owner = "tahoe-lafs";
    repo = "tahoe-lafs";
    rev = "6c1a37c95188c1d9a877286ef726280a68d38a4b";
    sha256 = "1fd8b6j52wn04bnvnvysws4c713max6k1592lz4nzyjlhrcwawwh";
  };
  propagatedBuildInputs = old.propagatedBuildInputs ++ [ eliot ] ++ plugins;
  doInstallCheck = false;
})
