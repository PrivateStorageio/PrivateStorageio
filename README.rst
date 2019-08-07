PrivateStorageio
================

The backend for a private, secure, and end-to-end encrypted storage solution

Building
--------

The build system uses `Nix`_ which must be installed before anything can be built.

Documentation
~~~~~~~~~~~~~

The documentation can be built using this command::

  nix-build docs.nix

The documentation is also built on and published by CI.

Testing
-------

The test system uses `Nix`_ which must be installed before any tests can be run.

Unit tests are run using this command::

  $ nix-build nixos/unit-tests.nix

Unit tests are also run on CI.

The system tests are run using this command::

  $ nix-build nixos/system-tests.nix

The system tests boot QEMU VMs which prevents them from running on CI at this time.
