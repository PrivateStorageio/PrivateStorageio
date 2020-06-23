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
from time import sleep, ctime
from pprint import pprint

import requests
import hyperlink

def main():
    (clientDir,) = argv[1:]

    someData = urandom(2 ** 16)

    api_root = get_api_root(clientDir)

    block_until_connected(api_root)

    subject_cap = exercise_immutable(api_root, someData)
    newDir = exercise_mkdir(api_root)
    exercise_link_unlink(api_root, newDir, subject_cap)

def block_until_connected(api_root):
    """
    Block until the Tahoe-LAFS node at the given API root reports it has
    connected to at least one storage server.
    """
    while True:
        response = requests.get(
            api_root.replace(query={u"t": u"json"}),
        )
        response.raise_for_status()
        welcome = response.json()
        servers = welcome["servers"]
        connected = list(
            server
            for server
            in servers
            if server["connection_status"].startswith("Connected to ")
        )
        if len(connected) >= 1:
            print(
                "Connected to a server:\n"
                "\t{nodeid}\n"
                "\t{status}\n"
                "\t{last_received_data}\n".format(
                    nodeid=connected[0]["nodeid"],
                    status=connected[0]["connection_status"],
                    last_received_data=ctime(connected[0]["last_received_data"]),
                ),
            )
            return
        pprint(welcome)
        sleep(0.1)

def exercise_immutable(api_root, someData):
    cap = tahoe_put(api_root, someData)
    dataReadBack = tahoe_get(api_root, cap)
    assert someData == dataReadBack
    return cap

def exercise_mkdir(api_root):
    cap = tahoe_mkdir(api_root)
    info = tahoe_stat(api_root, cap)
    assert info
    return info[1][u"rw_uri"]

def exercise_link_unlink(api_root, dir_cap, subject_cap):
    tahoe_link(api_root, dir_cap, u"foo", subject_cap)
    assert u"foo" in tahoe_stat(api_root, dir_cap)[1][u"children"]
    tahoe_unlink(api_root, dir_cap, u"foo")
    assert u"foo" not in tahoe_stat(api_root, dir_cap)[1][u"children"]

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
    response = requests.put(
        api_root.child(u"uri", dir_cap, name).replace(query={u"t": u"uri"}).to_uri(),
        BytesIO(subject_cap.encode("ascii")),
    )
    response.raise_for_status()
    return response.text

def tahoe_stat(api_root, cap):
    response = requests.get(
        api_root.child(u"uri", cap).replace(query={u"t": u"json"}).to_uri(),
    )
    response.raise_for_status()
    return response.json()

def tahoe_unlink(api_root, dir_cap, name):
    response = requests.delete(
        api_root.child(u"uri", dir_cap, name).to_uri(),
    )
    response.raise_for_status()
    return response.text

if __name__ == u'__main__':
    main()
