Morph
=====

This directory contains Nix-based configuration for the grid.
This takes the form of Nix expressions in ``.nix`` files
and some JSON-based configuration in ``.json`` files.

This configuration is fed to `morph`_ to make changes to the deployment.

Deploying
`````````

The deployment consists of the public software packages and the private secrets.
You can deploy these together::

  morph deploy --upload-secrets morph/grid/<testing|production|...>/grid.nix test

Or separately::

  morph deploy morph/grid/<testing|production|...>/grid.nix test
  morph upload-secrets morph/grid/<testing|production|...>/grid.nix

Separate deployment is useful when the software deploy is done from system which may not be sufficiently secure to host the secrets
(such as a cloud build machine).
Secrets should only be hosted on an extremely secure system
(XXX write the document for what this means).

Note secrets only need to be uploaded after a host in the grid has been rebooted or when the secrets have changed.

See the ``morph`` and ``nixos-rebuild`` documentation for more details about these commands.

Filesystem Layout
`````````````````

lib
---

This contains Nix library code for defining the grids.

grid
----

Specific grid definitions live in subdirectories beneath this directory.

config.json
~~~~~~~~~~~

As much as possible of the static configuration for the PrivateStorage.io application is provided in this file.
It is read by **grid.nix**.

grid.nix
~~~~~~~~

This is the `morph`_ entrypoint for the grid.
This defines all of the servers that are part of the grid.

The actual configuration is split into separate files that are imported from this one.
You can do things like build the network::

  morph build grid.nix


<hostname>-hardware.nix
~~~~~~~~~~~~~~~~~~~~~~~

These are the generated hardware-related configuration files for servers in the grid.
These files are referenced from the corresponding ``<hostname>.nix`` files.

<hostname>-config.nix
~~~~~~~~~~~~~~~~~~~~~

Each such file contains a minimal Nix expression supplying critical system configuration details.
"Critical" roughly corresponds to anything which must be specified to have a bootable system.
These files are referenced by the corresponding ``<hostname>.nix`` files.

Configuring New Storage Nodes
`````````````````````````````

Storage nodes are brought into the grid in a multi-step process.
Here are the steps to configure a new node,
starting from a minimal NixOS 19.03 or 19.09 installation.

#. Copy the remote file ``/etc/nixos/hardware-configuration.nix`` to the local file ``storageNNN-hardware.nix``.
   In the case of an EC2 instance, copy the remote file ``/etc/nixos/configuration.nix`` instead.
#. Add ``"zfs"`` to ``boot.supportedFilesystems`` in ``storageNNN-hardware.nix``.
#. Add a unique value for ``networking.hostId`` in ``storageNNN-hardware.nix``.
#. Copy ``storageNNN-hardware.nix`` back to ``/etc/nixos/hardware-configuration.nix``.
#. Run ``nixos-rebuild test``.
#. Manually create a storage zpool::

     zpool create -m legacy -o ashift=12 root raidz /dev/disk/by-id/{...}

#. Mount the new ZFS filesystem to verify it is working::

     mkdir /storage
     mount -t zfs root /storage

#. Add a new filesystem entry to ``storageNNN-hardware.nix``::

     # Manually created using:
     #   zpool create -f -m legacy -o ashift=12 root raidz ...
     fileSystems."/storage" = {
       device = "root";
       fsType = "zfs";
     };

#. Create a ``storageNNN-config.nix`` containing further configuration for the new host.
#. Add an entry for the new host to ``grid.nix`` referencing the new files.
#. Deploy to the new host with ``morph deploy morph/.../grid.nix --on <identifier> boot --upload-secrets --reboot``.

.. _`morph`: https://github.com/DBCDK/morph
