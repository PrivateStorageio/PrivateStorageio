{ pkgs ? import <nixpkgs> { } }:
let lib = pkgs.lib;
in rec {
  # Map a function over an attrset and concatenate the string results.
  #
  # concatMapAttrsToList (n: v: "${n} = ${v}\n") { a = "b"; c = "d"; } -> "a = b\nc = d\n"
  concatMapAttrsToList = f: a:
    lib.strings.concatStrings (lib.attrsets.mapAttrsToList f a);

  # Generate one line of configuration defining one item in one section.
  #
  # oneConfigItemText "foo" "bar" -> "foo = bar\n"
  oneConfigItemText = name: value:
    "${name} = ${builtins.toString value}\n";

  # Generate all lines of configuration defining all items in one section.
  #
  # allConfigItemsText { foo = "bar"; baz = "quux"; } -> "foo = bar\nbaz = quux"
  allConfigItemsText = items:
    concatMapAttrsToList oneConfigItemText items;

  # Generate all lines of configuration for one section, header
  # and items included.
  #
  # oneConfigSectionText "foo" { bar = "baz"; } -> "[foo]\nbar = baz\n"
  oneConfigSectionText = name: value: ''
    [${name}]
    ${allConfigItemsText value}
    '';

  # Generate all lines of configuration for all sections, headers
  # and items included.
  #
  # allConfigSectionsText { foo = { bar = "baz"; }; } -> "[foo]\nbar = baz\n"
  allConfigSectionsText = sections:
    concatMapAttrsToList oneConfigSectionText sections;
}
