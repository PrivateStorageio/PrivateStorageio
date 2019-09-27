#!/usr/bin/env python3

from sys import argv
from os import environ, makedirs, rename
from shutil import which
from subprocess import check_output
from socket import socket
from time import sleep

log = print

def main():
    pemFile, introducerPort, introducerFURL = argv[1:]

    # PYTHONHOME set for Python 3 for this script breaks Python 2 used by
    # Tahoe. :/ This is kind of a NixOS Python packaging bug.
    del environ["PYTHONHOME"]

    run(["tahoe", "--version"])
    run([
        "tahoe", "create-introducer",
        "--port", "tcp:" + introducerPort,
        "--location", "tcp:introducer:" + introducerPort,
        "/tmp/introducer",
    ])
    rename(pemFile, "/tmp/introducer/private/node.pem")
    with open("/tmp/introducer/private/introducer.furl", "w") as f:
        f.write(introducerFURL)
    run([
        "daemonize",
        "-o", "/tmp/stdout",
        "-e", "/tmp/stderr",
        which("tahoe"), "run", "/tmp/introducer",
    ])

    retry(
        "waiting for open introducer port",
        lambda: checkOpen(int(introducerPort)),
    )


def checkOpen(portNumber):
    s = socket()
    try:
        s.connect(("127.0.0.1", portNumber))
    except:
        return False
    else:
        return True
    finally:
        s.close()


def retry(description, f):
    for i in range(60):
        log("trying to {}...".format(description))
        if f():
            log("{} succeeded".format(description))
            return
        sleep(1.0)
    raise ValueError("failed to {} after many tries".format(description))


def run(argv):
    log("Running {}".format(argv))
    log("{}: {}".format(argv, check_output(argv)))


if __name__ == '__main__':
    main()
