from flask import Flask, jsonify, request
import stripe
import json

stripe.api_key = "sk_test_abcdef"

app = Flask(__name__)


@app.route('/create-payment-intent', methods=['POST'])
def create_payment():
    # Use an existing Customer ID if this is a returning customer
    customer = stripe.Customer.create()

    data = json.loads(request.data)

    # Each payment method type has support for different currencies. In order to
    # support many payment method types and several currencies, this server
    # endpoint accepts both the payment method type and the currency as
    # parameters.
    #
    # Some example payment method types include `card`, `ideal`, and `alipay`.
    payment_method_type = data['paymentMethodType']
    currency = data['currency']

    # Create a PaymentIntent with the amount, currency, and a payment method type.
    #
    # See the documentation [0] for the full list of supported parameters.
    #
    # [0] https://stripe.com/docs/api/payment_intents/create
    params = {
        'payment_method_types': [payment_method_type],
        'amount': 999,
        'currency': currency,
        'customer': customer['id'],
        'capture_method': 'manual',
        'setup_future_usage': 'off_session',
    }

    try:
        intent = stripe.PaymentIntent.create(**params)
        # Send PaymentIntent details to the front end.
        return jsonify({'clientSecret': intent.client_secret})

    except stripe.error.StripeError as e:
        return jsonify({'error': {'message': str(e)}}), 400

    except Exception as e:
        return jsonify({'error': {'message': str(e)}}), 400


@app.route('/confirm-payment-intent', methods=['POST'])
def confirm_payment():
    data = json.loads(request.data)

    # Each payment method type has support for different currencies. In order to
    # support many payment method types and several currencies, this server
    # endpoint accepts both the payment method type and the currency as
    # parameters.
    payment_intent = data['paymentIntentId']
    payment_method = data['paymentMethodId']

    # Confirm the PaymentIntent only for certain card networks
    #
    # See the documentation [0] for the full list of supported parameters.
    #
    # [0] https://stripe.com/docs/api/payment_intents/create
    # params = {
    #     'payment_method_options': {
    #         'card': {
    #             'network': ['visa', 'mastercard']
    #         }
    #     },
    # }

    try:
        intent = stripe.PaymentIntent.confirm(
            payment_intent, payment_method=payment_method)
        print(intent)
        # Send PaymentIntent details to the front end.
        return jsonify({'clientSecret': intent.client_secret})
    except stripe.error.StripeError as e:
        return jsonify({'error': {'message': str(e)}}), 400

    except Exception as e:
        return jsonify({'error': {'message': str(e)}}), 400


@app.route('/config', methods=['GET'])
def get_config():
    return jsonify({'publishableKey': "pk_test_abcdef"})


if __name__ == '__main__':
    app.run(debug=True)
