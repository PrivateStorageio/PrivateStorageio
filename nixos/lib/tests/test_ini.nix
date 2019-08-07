ini:
{ test_empty =
  { expected = "";
    expr = ini.allConfigSectionsText { };
  };

  test_one_empty_section =
  { expected = ''
    [foo]
    '';
    expr = ini.allConfigSectionsText { foo = { }; };
  };

  test_one_section_one_item =
  { expected = ''
    [foo]
    bar = baz
    '';
    expr = ini.allConfigSectionsText { foo = { bar = "baz"; }; };
  };

  test_one_section_two_items =
  { expected = ''
    [foo]
    bar = baz
    foobar = quux
    '';
    expr = ini.allConfigSectionsText { foo = { bar = "baz"; foobar = "quux"; }; };
  };

  test_two_sections =
  { expected = ''
    [alpha]
    beta = gamma
    [foo]
    bar = baz
    foobar = quux
    '';
    expr = ini.allConfigSectionsText
    { foo = { bar = "baz"; foobar = "quux"; };
      alpha = { beta = "gamma"; };
    };
  };

  test_true =
  { expected = "x = true\n";
    expr = ini.oneConfigItemText "x" true;
  };

  test_false =
  { expected = "x = false\n";
    expr = ini.oneConfigItemText "x" false;
  };

  test_integer =
  { expected = "x = 12345\n";
    expr = ini.oneConfigItemText "x" 12345;
  };
}
