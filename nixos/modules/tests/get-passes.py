#!/usr/bin/env python3

from sys import argv
from requests import post, get, put
from json import dumps
from time import sleep

def main():
    clientAPIRoot, issuerAPIRoot = argv[1:]

    # Construct a voucher that's acceptable to various parts of the system.
    voucher = "a" * 44

    zkapauthz = clientAPIRoot + "/storage-plugins/privatestorageio-zkapauthz-v1"

    # Simulate a payment for a voucher.
    post(
        issuerAPIRoot + "/v1/stripe/webhook",
        dumps(charge_succeeded_json(voucher)),
        headers={"content-type": "application/json"},
    )

    # Tell the client to redeem the voucher.
    response = put(
        zkapauthz + "/voucher",
        dumps({"voucher": voucher}),
    )
    if response.status_code // 100 != 2:
        print("Unexpected response: {}".format(response.content))
        response.raise_for_status()

    # Poll the vouchers list for a while to see it get redeemed.
    expected = {"version": 1, "number": voucher, "redeemed": True}
    def find_redeemed_voucher():
        response = get(zkapauthz + "/voucher/" + voucher)
        response.raise_for_status()
        actual = response.json()
        print("Actual response: {}".format(actual))
        return expected == actual

    retry(
        "find redeemed voucher",
        find_redeemed_voucher,
    )


def retry(description, f):
    for i in range(60):
        print("trying to {}...".format(description))
        if f():
            print("{} succeeded".format(description))
            break
        sleep(1.0)
    raise ValueError("failed to {} after many tries".format(description))


def charge_succeeded_json(voucher):
    # This structure copy/pasted from Stripe webhook web interface.
    base_payload = {
        "id": "evt_1FKSX2DeTd13VRuuhPaUDA2f",
        "object": "event",
        "api_version": "2016-07-06",
        "created": 1568910660,
        "data": {
            "object": {
                "id": "ch_1FKSX2DeTd13VRuuG9BXbqji",
                "object": "charge",
                "amount": 999,
                "amount_refunded": 0,
                "application": None,
                "application_fee": None,
                "application_fee_amount": None,
                "balance_transaction": "txn_1FKSX2DeTd13VRuuqO1CJZ1e",
                "billing_details": {
                    "address": {
                        "city": None,
                        "country": None,
                        "line1": None,
                        "line2": None,
                        "postal_code": None,
                        "state": None
                    },
                    "email": None,
                    "name": None,
                    "phone": None
                },
                "captured": True,
                "created": 1568910660,
                "currency": "usd",
                "customer": None,
                "description": None,
                "destination": None,
                "dispute": None,
                "failure_code": None,
                "failure_message": None,
                "fraud_details": {
                },
                "invoice": None,
                "livemode": False,
                "metadata": {
                    "Voucher": None,
                },
                "on_behalf_of": None,
                "order": None,
                "outcome": {
                    "network_status": "approved_by_network",
                    "reason": None,
                    "risk_level": "normal",
                    "risk_score": 44,
                    "seller_message": "Payment complete.",
                    "type": "authorized"
                },
                "paid": True,
                "payment_intent": None,
                "payment_method": "card_1FKSX2DeTd13VRuus5VEjmjG",
                "payment_method_details": {
                    "card": {
                        "brand": "visa",
                        "checks": {
                            "address_line1_check": None,
                            "address_postal_code_check": None,
                            "cvc_check": None
                        },
                        "country": "US",
                        "exp_month": 9,
                        "exp_year": 2020,
                        "fingerprint": "HTJeRR4MXhAAkctF",
                        "funding": "credit",
                        "last4": "4242",
                        "three_d_secure": None,
                        "wallet": None
                    },
                    "type": "card"
                },
                "receipt_email": None,
                "receipt_number": None,
                "receipt_url": "https://pay.stripe.com/receipts/acct_198xN4DeTd13VRuu/ch_1FKSX2DeTd13VRuuG9BXbqji/rcpt_Fq8oAItSiNmcm0beiie6lUYin920E7a",
                "refunded": False,
                "refunds": {
                    "object": "list",
                    "data": [
                    ],
                    "has_more": False,
                    "total_count": 0,
                    "url": "/v1/charges/ch_1FKSX2DeTd13VRuuG9BXbqji/refunds"
                },
                "review": None,
                "shipping": None,
                "source": {
                    "id": "card_1FKSX2DeTd13VRuus5VEjmjG",
                    "object": "card",
                    "address_city": None,
                    "address_country": None,
                    "address_line1": None,
                    "address_line1_check": None,
                    "address_line2": None,
                    "address_state": None,
                    "address_zip": None,
                    "address_zip_check": None,
                    "brand": "Visa",
                    "country": "US",
                    "customer": None,
                    "cvc_check": None,
                    "dynamic_last4": None,
                    "exp_month": 9,
                    "exp_year": 2020,
                    "fingerprint": "HTJeRR4MXhAAkctF",
                    "funding": "credit",
                    "last4": "4242",
                    "metadata": {
                    },
                    "name": None,
                    "tokenization_method": None
                },
                "source_transfer": None,
                "statement_descriptor": None,
                "statement_descriptor_suffix": None,
                "status": "succeeded",
                "transfer_data": None,
                "transfer_group": None
            }
        },
        "livemode": False,
        "pending_webhooks": 2,
        "request": "req_5ozjOIAcOkvVUK",
        "type": "charge.succeeded"
    }
    # Indicate the voucher the payment references.
    base_payload["data"]["object"]["metadata"]["Voucher"] = voucher
    return base_payload


if __name__ == '__main__':
    main()
