let
  pkgs = import <nixpkgs> { };
  ini = import ../ini.nix { inherit pkgs; };
in
pkgs.lib.runTests
{ test_empty =
  { name = "test_empty";
    expected = "";
    expr = ini.allConfigSectionsText { };
  };

  test_one_section =
  { name = "test_one_empty_section";
    expected = ''
    [foo]

    '';
    expr = ini.allConfigSectionsText { foo = { }; };
  };
}
