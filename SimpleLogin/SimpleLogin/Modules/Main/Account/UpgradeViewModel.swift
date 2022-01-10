//
//  UpgradeViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 29/12/2021.
//

import Combine
import StoreKit

final class UpgradeViewModel: NSObject, ObservableObject {
    @Published private(set) var monthlySubscription: SKProduct?
    @Published private(set) var yearlySubscription: SKProduct?

    func retrieveProductsInfo() {
        let request = SKProductsRequest(productIdentifiers: Set(Subscription.allCases.map { $0.productId }))
        request.delegate = self
        request.start()
    }

    func subscribeYearly() {}

    func subscribeMonthly() {}

    func restorePurchase() {}
}

// MARK: - SKProductsRequestDelegate
extension UpgradeViewModel: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            for product in response.products {
                switch product.productIdentifier {
                case Subscription.monthly.productId: self.monthlySubscription = product
                case Subscription.yearly.productId: self.yearlySubscription = product
                default: break
                }
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
