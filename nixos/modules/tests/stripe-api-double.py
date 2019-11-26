#!/usr/bin/env python3

from sys import stdout, argv
from json import dumps

from twisted.internet.defer import Deferred
from twisted.internet.endpoints import serverFromString
from twisted.internet.task import react
from twisted.web.resource import Resource
from twisted.web.server import Site
from twisted.python.log import startLogging

class Charges(Resource):
    def render_POST(self, request):
        voucher = request.args[b"metadata[Voucher]"][0].decode("utf-8")
        card = request.args[b"card"][0].decode("utf-8")
        amount = int(request.args[b"amount"][0])
        currency = request.args[b"currency"][0].decode("utf-8")
        response = dumps(charge(card, amount, currency, {u"Voucher": voucher}))
        return response.encode("utf-8")

def main(reactor, listenEndpoint):
    charges = Charges()
    v1 = Resource()
    v1.putChild(b"charges", charges)
    root = Resource()
    root.putChild(b"v1", v1)

    return serverFromString(reactor, listenEndpoint).listen(
        Site(root),
    ).addCallback(
        lambda ignored: Deferred()
    )

def charge(source, amount, currency, metadata):
    return {
        "id": "ch_1Fj8frBHXBAMm9bPkekylvAq",
        "object": "charge",
        "amount": amount,
        "amount_refunded": 0,
        "application": None,
        "application_fee": None,
        "application_fee_amount": None,
        "balance_transaction": "txn_1Fj8fr2eZvKYlo2CC5JzIGj5",
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
        "captured": False,
        "created": 1574792527,
        "currency": currency,
        "customer": None,
        "description": None,
        "dispute": None,
        "disputed": False,
        "failure_code": None,
        "failure_message": None,
        "fraud_details": {},
        "invoice": None,
        "livemode": False,
        "metadata": metadata,
        "on_behalf_of": None,
        "order": None,
        "outcome": None,
        "paid": True,
        "payment_intent": None,
        "payment_method": source,
        "payment_method_details": {},
        "receipt_email": None,
        "receipt_number": None,
        "receipt_url": "https://pay.stripe.com/receipts/acct_1FhhxTBHXBAMm9bP/ch_1Fj8frBHXBAMm9bPkekylvAq/rcpt_GFdxYuDoGKfYgokh9YA11XhnYC7Gnxp",
        "refunded": False,
        "refunds": {
            "object": "list",
            "data": [],
            "has_more": False,
            "url": "/v1/charges/ch_1Fj8frBHXBAMm9bPkekylvAq/refunds"
        },
        "review": None,
        "shipping": None,
        "source_transfer": None,
        "statement_descriptor": None,
        "statement_descriptor_suffix": None,
        "status": "succeeded",
        "transfer_data": None,
        "transfer_group": None,
        "source": source,
    }

if __name__ == '__main__':
    startLogging(stdout)
    react(main, argv[1:])
