Developer documentation
=======================

Building
--------

The build system uses `Nix`_ which must be installed before anything can be built.
Start by setting up the development/operations environment::

  $ nix-shell

Testing
-------

The test system uses `Nix`_ which must be installed before any tests can be run.

Unit tests are run using this command::

  $ nix-build nixos/unit-tests.nix

Unit tests are also run on CI.

The system tests are run using this command::

  $ nix-build nixos/system-tests.nix

The system tests boot QEMU VMs which prevents them from running on CI at this time.

Architecture overview
---------------------

.. graphviz:: architecture-overview.dot


.. _Nix: https://nixos.org/nix

