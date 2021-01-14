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

  $ sudo --preserve-env nix-build nixos/system-tests.nix

The system tests boot QEMU VMs which prevents them from running on CI at this time.
Starting VMs require elevated privileges,
which is the reason for the suggested ``sudo`` command,
together with the ``--preserve-env`` option to avoid escaping the ``nix-shell`` set up at the top.
The build requires > 10 GB of disk space,
and the VMs might be timing out on slow or busy machines.
If you run into timeouts,
try `raising the number of retries <https://github.com/PrivateStorageio/PrivateStorageio/blob/e8233d2/nixos/modules/tests/run-introducer.py#L55-L62>`_.

It is also possible go through the testing script interactively - useful for debugging::

  $ sudo --preserve-env nix-build -A private-storage.driver nixos/system-tests.nix

This will give you a result symlink in the current directory.
Inside that is bin/nixos-test-driver which gives you a kind of REPL for interacting with the VMs.
The kind of `Perl in this testScript <https://github.com/PrivateStorageio/PrivateStorageio/blob/78881a3/nixos/modules/tests/private-storage.nix#L180>`_ is what you can enter into this REPL.

Architecture overview
---------------------

.. graphviz:: architecture-overview.dot


.. _Nix: https://nixos.org/nix

