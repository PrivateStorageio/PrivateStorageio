Notes on creating a local development environment using `nixos-container <https://nixos.org/manual/nixos/stable/#ch-containers>`_.

$ sudo nixos-container create payments-1 --config '
services.openssh.enable = true;
users.users.flo.extraGroups = [ "wheel" ];
users.users.flo.openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHx7wJQNqKn8jOC4AxySRL2UxidNp7uIK9ad3pMb1ifF flo@fs-la-tryout-3"];
'

> host IP is 10.233.2.1, container IP is 10.233.2.2
> these derivations will be built:
>  /nix/store/0c06f8ky8rbz63qhgld...
>  [...]

$ sudo nixos-container start payments-1

Repeat all steps for "storage-1".

