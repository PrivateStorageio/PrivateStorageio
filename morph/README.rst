This Directory
==============

This directory contains Nix-based configuration for the grid.
This takes the form of Nix expressions in ``.nix`` files
and some JSON-based configuration in ``.config.json`` files.

This configuration is fed to `morph`_ to make changes to the deployment.

grid.config.json
----------------

This contains configuration for Tahoe-LAFS.

grid.nix
--------

This is the `morph`_ entrypoint for the grid.
This defines all of the servers that are part of the grid.

The actual configuration is split into separate files that are imported from this one.
You can do things like build the network::

  morph build grid.nix

.. _`morph`: https://github.com/DBCDK/morph
