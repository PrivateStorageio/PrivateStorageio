#!/usr/bin/env python3

#
# Create a new file via the web interface of a Tahoe-LAFS client node and then
# retrieve the contents of that file.  Exit with success if the retrieved
# contents match what was uploaded originally.
#

from sys import argv
from os import urandom
from subprocess import check_output
from io import BytesIO

import requests

def main():
    (clientDir,) = argv[1:]

    someData = urandom(2 ** 16)

    api_root = get_api_root(clientDir)
    cap = put(api_root, someData)
    dataReadBack = get(api_root, cap)

    assert someData == dataReadBack


def get_api_root(path):
    with open(path + u"/node.url") as f:
        return f.read().strip()


def put(api_root, data):
    response = requests.put(api_root + u"uri", BytesIO(data))
    response.raise_for_status()
    return response.text


def get(api_root, cap):
    response = requests.get(api_root + u"uri/" + cap, stream=True)
    response.raise_for_status()
    return response.raw.read()


if __name__ == u'__main__':
    main()
