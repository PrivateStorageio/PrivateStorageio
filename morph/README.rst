Morph
=====

This directory contains Nix-based configuration for the grid.
This takes the form of Nix expressions in ``.nix`` files
and some JSON-based configuration in ``.config.json`` files.

This configuration is fed to `morph`_ to make changes to the deployment.

bootstrap-configuration.nix
---------------------------

This is meant as a minimal system configuration to use as part of crossgrading a Debian install to NixOS.
It has a lot of comments explaining different parts of Nix and NixOS.
You may want to browse it before looking at other ``.nix`` files here.

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

<hostname>-hardware.nix
-----------------------

These are the generated hardware-related configuration files for servers in the grid.
These files are referenced from the corresponding ``<hostname>.nix`` files.

<hostname>-config.nix
---------------------

Each such file contains a minimal Nix expression supplying critical system configuration details.
"Critical" roughly corresponds to anything which must be specified to have a bootable system.
These files are referenced by the corresponding ``<hostname>.nix`` files.

<hostname>.nix
--------------

Each such file contains the parts of the system configuration that aren't *so* related to hardware.
They are referenced from ``grid.nix``.

.. _`morph`: https://github.com/DBCDK/morph
