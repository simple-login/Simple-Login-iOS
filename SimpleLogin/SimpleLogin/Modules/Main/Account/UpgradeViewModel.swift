//
//  UpgradeViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 29/12/2021.
//

import Combine
import StoreKit
import SwiftyStoreKit

final class UpgradeViewModel: NSObject, ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var monthlySubscription: SKProduct?
    @Published private(set) var yearlySubscription: SKProduct?
    @Published private(set) var isSubscribed = false
    private var cancellables = Set<AnyCancellable>()

    func handledError() {
        self.error = nil
    }

    func retrieveProductsInfo() {
        let productIds = Set(Subscription.allCases.map { $0.productId })
        SwiftyStoreKit.retrieveProductsInfo(productIds) { result in
            if let error = result.error {
                self.error = error
            } else {
                for product in result.retrievedProducts {
                    switch product.productIdentifier {
                    case Subscription.monthly.productId: self.monthlySubscription = product
                    case Subscription.yearly.productId: self.yearlySubscription = product
                    default: break
                    }
                }
            }
        }
    }

    func subscribeYearly(session: Session) {
        purchase(yearlySubscription, session: session)
    }

    func subscribeMonthly(session: Session) {
        purchase(monthlySubscription, session: session)
    }

    func restorePurchase(session: Session) {
        fetchAndSendReceipt(session: session)
    }

    private func purchase(_ product: SKProduct?, session: Session) {
        guard let product = product, !isLoading else { return }
        isLoading = true
        SwiftyStoreKit.purchaseProduct(product) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success:
                self.fetchAndSendReceipt(session: session)
            case .error(let error):
                self.error = error
            case .deferred:
                break
            }
        }
    }

    private func fetchAndSendReceipt(session: Session) {
        isLoading = true
        SwiftyStoreKit.fetchReceipt(forceRefresh: false) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let receiptData):
                let encryptedReceipt = receiptData.base64EncodedString()
                session.client.processPayment(apiKey: session.apiKey,
                                              receiptData: encryptedReceipt,
                                              isMacApp: false)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] completion in
                        guard let self = self else { return }
                        self.isLoading = false
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            self.error = error
                        }
                    } receiveValue: { [weak self] okResponse in
                        self?.isSubscribed = okResponse.value
                    }
                    .store(in: &self.cancellables)

            case .error(let error):
                self.isLoading = false
                self.error = error
            }
        }
    }
}

enum Subscription: CaseIterable {
    case monthly, yearly

    var productId: String {
        switch self {
        case .monthly: return "io.simplelogin.ios_app.subscription.premium.monthly"
        case .yearly: return "io.simplelogin.ios_app.subscription.premium.yearly"
        }
    }
}

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price) ?? "\(price)"
    }
}

extension SKError.Code {
    var localizedDescription: String {
        switch self {
        case .clientInvalid:
            return "You are not allowed to perform the attempted action"
        case .paymentCancelled:
            return "Payment request canceled"
        case .paymentInvalid:
            return "One of the payment parameters was not recognized by the App Store"
        case .paymentNotAllowed:
            return "You are not allowed to authorize payments"
        case .storeProductNotAvailable:
            return "The requested product is not available in the store"
        case .cloudServicePermissionDenied:
            return "You have not allowed access to Cloud service information"
        case .cloudServiceNetworkConnectionFailed:
            return "The device could not connect to the network"
        case .cloudServiceRevoked:
            return "You have revoked permission to use this cloud service"
        case .privacyAcknowledgementRequired:
            return "You have not yet acknowledged Apple’s privacy policy for Apple Music"
        case .unauthorizedRequestData:
            return "The app is attempting to use a property for which it does not have the required entitlement"
        case .invalidOfferIdentifier:
            return "The offer identifier cannot be found or is not active"
        case .invalidOfferPrice:
            return "The price in App Store Connect is no longer valid"
        case .invalidSignature:
            return "The signature in a payment discount is not valid"
        case .missingOfferParams:
            return "Parameters are missing in a payment discount"
        case .ineligibleForOffer:
            return "You are not ineligible for the subscription offer"
        case .overlayCancelled:
            return "Overlay cancelled"
        case .overlayInvalidConfiguration:
            return "The overlay’s configuration is invalid"
        case .overlayPresentedInBackgroundScene:
            return "Overlay presented in background scene"
        case .overlayTimeout:
            return "Overlay timeout"
        case .unsupportedPlatform:
            return "The current platform does not support overlays"
        case .unknown:
            return "Unknown SKError (\(self.rawValue))"
        @unknown default:
            return "Unknown default SKError (\(self.rawValue))"
        }
    }
}
