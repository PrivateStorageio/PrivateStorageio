# The overall unit test suite for PrivateStorageio NixOS configuration.
let
  pkgs = import <nixpkgs> { };

  # Total the numbers in a list.
  sum = builtins.foldl' (a: b: a + b) 0;

  # A helper for loading tests.
  loadTest = moduleUnderTest: testModule:
    (import testModule (pkgs.callPackage moduleUnderTest { }));

  # A list of tests to run.  Manually updated for now, alas.  Only tests in
  # this list will be run!
  testModules =
  [ (loadTest ./lib/ini.nix ./lib/tests/test_ini.nix)
  ];

  # Count up the tests we're going to run.
  numTests = sum (map (s: builtins.length (builtins.attrNames s)) testModules);

  # Convert it into a string for interpolation into the shell script.
  numTestsStr = builtins.toString numTests;

  # Run the tests and collect the failures.
  failures = map pkgs.lib.runTests testModules;

  # Count the number of failures in each module.
  numFailures = sum (map builtins.length failures);

  # Convert the total into a string for easy interpolation into the shell script.
  numFailuresStr = builtins.toString (numFailures);

  # Convert the failure information to a string for reporting.
  failuresStr = builtins.toJSON failures;
in
pkgs.runCommand "test-results" {} ''
if [ ${numFailuresStr} -gt 0 ]; then
  echo "Failed ${numFailuresStr} tests"
  echo '${failuresStr}'
  exit 1
else
  echo '${numTestsStr} tests OK' > $out
fi
''
