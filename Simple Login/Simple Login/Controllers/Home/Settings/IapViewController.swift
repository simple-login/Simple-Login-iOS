//
//  IapViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 18/04/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import Toaster
import MBProgressHUD
import StoreKit
import SwiftyStoreKit

final class IapViewController: UIViewController, Storyboarded {
    @IBOutlet private weak var monthlyButton: UIButton!
    @IBOutlet private weak var yearlyButton: UIButton!
    
    private var productMonthly: SKProduct?
    private var productYearly: SKProduct?
    
    deinit {
        print("IapViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchProducts()
    }
    
    @IBAction private func monthlyButtonTapped() {
        guard let productMonthly = productMonthly else {
            Toast.displayShortly(message: "Unknown product")
            return
        }
        
        buy(productMonthly)
    }
    
    @IBAction private func yearlyButtonTapped() {
        guard let productYearly = productYearly else {
            Toast.displayShortly(message: "Unknown product")
            return
        }
        
        buy(productYearly)
    }
    
    private func buy(_ product: SKProduct) {
        
    }
    
    private func fetchProducts() {
        MBProgressHUD.showAdded(to: view, animated: true)
        SwiftyStoreKit.retrieveProductsInfo(Set([IapProduct.monthly.productId, IapProduct.yearly.productId])) { [weak self] (results) in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let error = results.error {
                Toast.displayError(error.localizedDescription)
                return
            }
            
            for product in results.retrievedProducts {
                switch product.productIdentifier {
                case IapProduct.monthly.productId: self.productMonthly = product
                case IapProduct.yearly.productId: self.productYearly = product
                default: break
                }
            }
            
            self.updateButtons()
        }
    }
    
    private func updateButtons() {
        guard let productMonthly = productMonthly, let productYearly = productYearly else {
            Toast.displayShortly(message: "Error retrieving products")
            return
        }
        
        monthlyButton.setTitle("\(productMonthly.regularPrice ?? "") (monthly)", for: .normal)
        yearlyButton.setTitle("\(productYearly.regularPrice ?? "") (yearly)", for: .normal)
    }
}
