#!/usr/bin/env python3

from os import environ
from sys import argv
from shutil import which
from subprocess import check_output

def main():
    (introducerFURL,) = argv[1:]

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
