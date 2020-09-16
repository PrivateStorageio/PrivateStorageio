#!/usr/bin/env python3

#
# Get a paid voucher and tell the Tahoe-LAFS client node to redeem it for some
# ZKAPs from an issuer.  Exit with success when the Tahoe-LAFS client node
# reports that the voucher has been redeemed.
#

from sys import argv
from requests import post, get, put
from json import dumps
from time import sleep

def main():
    if len(argv) != 5:
        raise SystemExit(
            "usage: %s <client api root> <client api token path> <issuer api root> <voucher>",
        )
    clientAPIRoot, clientAPITokenPath, issuerAPIRoot, voucher = argv[1:]
    if not clientAPIRoot.endswith("/"):
        clientAPIRoot += "/"
    if not issuerAPIRoot.endswith("/"):
        issuerAPIRoot += "/"

    zkapauthz = clientAPIRoot + "storage-plugins/privatestorageio-zkapauthz-v1"

    with open(clientAPITokenPath) as p:
        clientAPIToken = p.read().strip()

    # Submit a charge to the issuer (which is also the PaymentServer).
    charge_response = post(
        issuerAPIRoot + "v1/stripe/charge",
        dumps(charge_json(voucher)),
        headers={
            "content-type": "application/json",
        },
    )
    charge_response.raise_for_status()

    # Tell the client to redeem the voucher.
    response = put(
        zkapauthz + "/voucher",
        dumps({"voucher": voucher}),
        headers={
            "content-type": "application/json",
            "authorization": "tahoe-lafs " + clientAPIToken,
        }

    )
    if response.status_code // 100 != 2:
        print("Unexpected response: {}".format(response.content))
        response.raise_for_status()

    # Poll the vouchers list for a while to see it get redeemed.
    def find_redeemed_voucher():
        response = get(
            zkapauthz + "/voucher/" + voucher,
            headers={
                "authorization": "tahoe-lafs " + clientAPIToken,
            },
        )
        response.raise_for_status()
        actual = response.json()
        print("Actual response: {}".format(actual))
        try:
            check = (
                actual["version"],
                actual["number"],
                actual["state"]["name"],
            )
        except Exception as e:
            print("Check failed: {}".format(e))
            return False
        else:
            print("Checking {}".format(check))
            return check == (1, voucher, "redeemed")

    retry(
        "find redeemed voucher",
        find_redeemed_voucher,
    )


def retry(description, f):
    for i in range(60):
        print("trying to {}...".format(description))
        if f():
            print("{} succeeded".format(description))
            return
        sleep(1.0)
    raise ValueError("failed to {} after many tries".format(description))


def charge_json(voucher):
    return {
        "token": "tok_abcdef",
        "voucher": voucher,
        "amount": "100",
        "currency": "USD",
    }

if __name__ == '__main__':
    main()
