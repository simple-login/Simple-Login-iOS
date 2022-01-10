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
    @Published private(set) var error: String?
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
                self.error = error.localizedDescription
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
        fetchAndSendReceiptToBackend(session: session)
    }

    private func purchase(_ product: SKProduct?, session: Session) {
        guard let product = product, !isLoading else { return }
        isLoading = true
        SwiftyStoreKit.purchaseProduct(product) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success: self.fetchAndSendReceiptToBackend(session: session)
            case .error(let error): self.error = error.localizedDescription
            case .deferred: break
            }
        }
    }

    private func fetchAndSendReceiptToBackend(session: Session) {
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
                        case .finished: break
                        case .failure(let error): self.error = error.description
                        }
                    } receiveValue: { [weak self] okResponse in
                        self?.isSubscribed = okResponse.value
                    }
                    .store(in: &self.cancellables)

            case .error(let error):
                self.error = error.localizedDescription
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
