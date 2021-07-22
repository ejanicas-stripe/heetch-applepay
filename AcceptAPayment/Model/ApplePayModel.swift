//
//  ApplePayModel.swift
//  AcceptAPayment
//
//  Created by Eduardo Janicas on 7/20/21.

import Foundation
import Stripe
import PassKit

class ApplePayModel : NSObject, ObservableObject, STPApplePayContextDelegate {
    @Published var paymentStatus: STPPaymentStatus?
    @Published var lastPaymentError: Error?
    var clientSecret: String?
    var paymentIntentId: String?
    
    func pay(clientSecret: String?, paymentIntentId: String?) {
        self.clientSecret = clientSecret
        self.paymentIntentId = paymentIntentId
        // Configure a payment request
        let pr = StripeAPI.paymentRequest(withMerchantIdentifier: "merchant.dev.ejanicas", country: "GB", currency: "GBP")
        
        pr.supportedNetworks = [
            PKPaymentNetwork.visa,
            PKPaymentNetwork.masterCard
        ]
        // The entire UI is presented via a Remote View Controller.
        // This means that outside the PKPaymentRequest you give it, it’s impossible to otherwise style or modify the contents of this view.
        pr.requiredShippingContactFields = []
        pr.requiredBillingContactFields = []
//        let firstClassShipping = PKShippingMethod(label: "First Class Mail", amount: NSDecimalNumber(string: "10.99"))
//        firstClassShipping.detail = "Arrives in 3-5 days"
//        firstClassShipping.identifier = "firstclass"
//        let rocketRidesShipping = PKShippingMethod(label: "Rocket Rides courier", amount: NSDecimalNumber(string: "10.99"))
//        rocketRidesShipping.detail = "Arrives in 1-2 hours"
//        rocketRidesShipping.identifier = "rocketrides"
//        pr.shippingMethods = [
//            firstClassShipping,
//            rocketRidesShipping
//        ]
        // Build payment summary items
        // (You'll generally want to configure these based on the selected address and shipping method.
        pr.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "Deluxe Ride", amount: NSDecimalNumber(string: "9.99")),
        ]
        // Present the Apple Pay Context:
        let applePayContext = STPApplePayContext(paymentRequest: pr, delegate: self)
        applePayContext?.presentApplePay()
    }
    
    
    func applePayContext(_ context: STPApplePayContext, didCreatePaymentMethod paymentMethod: STPPaymentMethod, paymentInformation: PKPayment, completion: @escaping STPIntentClientSecretCompletionBlock) {
        // MARK: Confirm the PaymentIntent on the backend
        // Call your backend to create and confirm a PaymentIntent and get its client secret
        let url = URL(string: BackendUrl + "confirm-payment-intent")!
        let json: [String: String?] = [
            "paymentIntentId": self.paymentIntentId,
            "paymentMethodId": paymentMethod.stripeId
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: json)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
                guard let response = response as? HTTPURLResponse,
                        response.statusCode == 200,
                        let data = data,
                        let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                        let clientSecret = json["clientSecret"] as? String else {
                            let message = error?.localizedDescription ?? "Failed to decode response from server."
                            print(message)
                            DispatchQueue.main.async {
                                self?.lastPaymentError = error
                            }
                            return
                }
                print("Confirmed PaymentIntent")
                DispatchQueue.main.async {
                    self?.clientSecret = clientSecret
                }
                completion(clientSecret, nil)
        })
        task.resume()
    }
    
    func applePayContext(_ context: STPApplePayContext, didCompleteWith status: STPPaymentStatus, error: Error?) {
        // When the payment is complete, display the status.
        self.paymentStatus = status
        self.lastPaymentError = error
    }
}
