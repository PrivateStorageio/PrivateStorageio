#!/usr/bin/env python2

from sys import argv
from os import urandom

def main():
    (clientDir,) = argv[1:]

    someData = urandom(2 ** 16)
    with mkstemp() as (fd, name):
        write(fd, someData)

        cap = get([
            "tahoe", "-d", clientDir,
            "put", name,
        ])

        dataReadBack = get([
            "tahoe", "-d", clientDir,
            "get", cap,
        ])

    assert someData == dataReadBack


def get(argv):
    return check_output(argv)


if __name__ == '__main__':
    main()
