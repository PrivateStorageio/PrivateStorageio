# Functionality related to writing out ini syntax files (like Tahoe-LAFS'
# tahoe.cfg).
{ pkgs }:
let lib = pkgs.lib;
in rec {
  # Get the .ini-file-appropriate string representation of a simple value.
  #
  # > toINIString "hello"
  # "hello"
  # > toINIString true
  # "true"
  toINIString = v:
    if builtins.isBool v then builtins.toJSON v
    else builtins.toString v;

  # Map a function over an attrset and concatenate the string results.
  #
  # > concatMapAttrsToList (n: v: "${n} = ${v}\n") { a = "b"; c = "d"; }
  # "a = b\nc = d\n"
  concatMapAttrsToList = f: a:
    lib.strings.concatStrings (lib.attrsets.mapAttrsToList f a);

  # Generate one line of configuration defining one item in one section.
  #
  # > oneConfigItemText "foo" "bar"
  # "foo = bar\n"
  oneConfigItemText = name: value:
    "${name} = ${toINIString value}\n";

  # Generate all lines of configuration defining all items in one section.
  #
  # > allConfigItemsText { foo = "bar"; baz = "quux"; }
  # "foo = bar\nbaz = quux"
  allConfigItemsText = items:
    concatMapAttrsToList oneConfigItemText items;

  # Generate all lines of configuration for one section, header
  # and items included.
  #
  # > oneConfigSectionText "foo" { bar = "baz"; }
  # "[foo]\nbar = baz\n"
  oneConfigSectionText = name: value: ''
    [${name}]
    ${allConfigItemsText value}'';

  # Generate all lines of configuration for all sections, headers
  # and items included.
  #
  # > allConfigSectionsText { foo = { bar = "baz"; }; }
  # "[foo]\nbar = baz\n"
  allConfigSectionsText = sections:
    concatMapAttrsToList oneConfigSectionText sections;
}
