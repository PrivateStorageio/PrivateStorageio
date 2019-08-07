# The overall test suite for PrivateStorageio NixOS configuration.
let
  pkgs = import <nixpkgs> { };

  # A helper for loading tests.
  loadTest = moduleUnderTest: testModule:
    (import testModule (pkgs.callPackage moduleUnderTest { }));

  # A list of tests to run.  Manually updated for now, alas.  Only tests in
  # this list will be run!
  testModules =
  [ (loadTest ./lib/ini.nix ./lib/tests/test_ini.nix)
  ];

  # Run the tests and collect the failures.
  failures = map pkgs.lib.runTests testModules;

  # Count the number of failures in each module.
  numFailures = builtins.foldl' (a: b: a + b) 0 (map builtins.length failures);

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
  echo 'OK' > $out
fi
''
