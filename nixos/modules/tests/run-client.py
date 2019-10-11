#!/usr/bin/env python3

#
# Create a PrivateStorage.io-enabled Tahoe-LAFS client node and run it as a
# daemon.  Exit with success when we think we've started it.
#

from os import environ
from sys import argv
from shutil import which
from subprocess import check_output
from configparser import ConfigParser

def main():
    (introducerFURL, issuerURL) = argv[1:]

    # PYTHONHOME set for Python 3 for this script breaks Python 2 used by
    # Tahoe. :/ This is kind of a NixOS Python packaging bug.
    del environ["PYTHONHOME"]

    run(["tahoe", "--version"])
    run([
        "tahoe", "create-client",
        "--shares-needed", "1",
        "--shares-happy", "1",
        "--shares-total", "1",
        "--introducer", introducerFURL,
        "/tmp/client",
    ])

    # Add necessary ZKAPAuthorizer configuration bits.
    config = ConfigParser()
    with open("/tmp/client/tahoe.cfg") as cfg:
        config.read_file(cfg)

    config.set(u"client", u"storage.plugins", u"privatestorageio-zkapauthz-v1")
    config.add_section(u"storageclient.plugins.privatestorageio-zkapauthz-v1")
    config.set(u"storageclient.plugins.privatestorageio-zkapauthz-v1", u"redeemer", u"ristretto")
    config.set(u"storageclient.plugins.privatestorageio-zkapauthz-v1", u"ristretto-issuer-root-url", issuerURL)

    with open("/tmp/client/tahoe.cfg", "wt") as cfg:
        config.write(cfg)

    run([
        "daemonize",
        "-o", "/tmp/stdout",
        "-e", "/tmp/stderr",
        which("tahoe"), "run", "/tmp/client",
    ])

def run(argv):
    print("{}: {}".format(argv, check_output(argv)))


if __name__ == '__main__':
    main()
