//
//  ApplePay.swift
//  AcceptAPayment
//
//  Created by Eduardo Janicas on 7/20/21.

import SwiftUI
import Stripe
import PassKit

struct ApplePay: View {
    @ObservedObject var backendModel = BackendModel()
    @StateObject var applePayModel = ApplePayModel()
    
    var body: some View {
        VStack {
            if backendModel.paymentIntentParams != nil {
                PaymentButton() {
                    applePayModel.pay(clientSecret: backendModel.paymentIntentParams?.clientSecret, paymentIntentId: backendModel.paymentIntentParams?.stripeId)
                }
                .padding()
            } else {
                Text("Loading...")
            }
            if let paymentStatus = applePayModel.paymentStatus {
                HStack {
                    switch paymentStatus {
                    case .success:
                        Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                        Text("Payment complete!")
                    case .error:
                        Image(systemName: "xmark.octagon.fill").foregroundColor(.red)
                        Text("Payment failed!")
                    case .userCancellation:
                        Image(systemName: "xmark.octagon.fill").foregroundColor(.orange)
                        Text("Payment canceled.")
                    @unknown default:
                        Text("Unknown status")
                    }
                }
            }
        }.onAppear {
            // When it’s time to check out, you’ll first need to see if Apple Pay is supported on the device you’re running and your customer has added any cards to Passbook
            let paymentNetworks = [PKPaymentNetwork.amex, PKPaymentNetwork.masterCard]
            if (!StripeAPI.deviceSupportsApplePay() ||  !PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks)) {
                print("Apple Pay is not supported on this device.")
            } else {
                backendModel.preparePaymentIntent(paymentMethodType: "card", currency: "gbp")
            }
        }
    }
}

struct ApplePay_Previews: PreviewProvider {
    static var previews: some View {
        ApplePay()
    }
}
