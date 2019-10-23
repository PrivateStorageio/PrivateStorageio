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
import hyperlink

def main():
    (clientDir,) = argv[1:]

    someData = urandom(2 ** 16)

    api_root = get_api_root(clientDir)

    exercise_immutable(api_root, someData)
    exercise_mkdir(api_root)

def exercise_immutable(api_root, someData):
    cap = tahoe_put(api_root, someData)
    dataReadBack = tahoe_get(api_root, cap)
    assert someData == dataReadBack
    return cap

def exercise_mkdir(api_root):
    cap = tahoe_mkdir(api_root)
    info = tahoe_stat(api_root, cap)
    assert info

def get_api_root(path):
    with open(path + u"/node.url") as f:
        return hyperlink.URL.from_text(f.read().strip())

def tahoe_put(api_root, data, **kwargs):
    response = requests.put(
        api_root.child(u"uri").to_uri(),
        BytesIO(data),
    )
    response.raise_for_status()
    return response.text

def tahoe_get(api_root, cap):
    response = requests.get(
        api_root.child(u"uri", cap).to_uri(),
        stream=True,
    )
    response.raise_for_status()
    return response.raw.read()

def tahoe_mkdir(api_root):
    response = requests.post(
        api_root.child(u"uri").replace(query={u"t": u"mkdir", u"format": u"mdmf"}).to_uri(),
    )
    response.raise_for_status()
    return response.text

def tahoe_link(api_root, dir_cap, name, subject_cap):
    response = requests.post(
        api_root.child(u"uri", dir_cap, name).replace(query={u"t": u"uri"}).to_uri(),
        BytesIO(subject_cap),
    )
    response.raise_for_status()
    return response.text

def tahoe_stat(api_root, cap):
    response = requests.get(
        api_root.child(u"uri", cap).replace(query={u"t": u"json"}).to_uri(),
    )
    response.raise_for_status()
    return response.json

if __name__ == u'__main__':
    main()
