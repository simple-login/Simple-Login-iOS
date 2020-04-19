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
    @IBOutlet private weak var rootScrollView: UIScrollView!
    @IBOutlet private weak var monthlyButton: UIButton!
    @IBOutlet private weak var yearlyButton: UIButton!
    @IBOutlet private weak var enterpriseButton: UIButton!
    
    private var productMonthly: SKProduct?
    private var productYearly: SKProduct?
    
    private var selectedIapProduct: IapProduct = .yearly {
        didSet {
            let radioSelectedImage = UIImage(named: "RadioSelected")
            let radioUnselectedImage = UIImage(named: "RadioUnselected")
            switch selectedIapProduct {
            case .yearly:
                yearlyButton.setImage(radioSelectedImage, for: .normal)
                monthlyButton.setImage(radioUnselectedImage, for: .normal)
            case .monthly:
                yearlyButton.setImage(radioUnselectedImage, for: .normal)
                monthlyButton.setImage(radioSelectedImage, for: .normal)
            }
        }
    }
    
    deinit {
        print("IapViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        fetchProducts()
        //fetchReceipt()
    }
//
//    @IBAction private func monthlyButtonTapped() {
//        guard let productMonthly = productMonthly else {
//            Toast.displayShortly(message: "Unknown product")
//            return
//        }
//
//        buy(productMonthly)
//    }
//
//    @IBAction private func yearlyButtonTapped() {
//        guard let productYearly = productYearly else {
//            Toast.displayShortly(message: "Unknown product")
//            return
//        }
//
//        buy(productYearly)
//    }
    
    private func setUpUI() {
        enterpriseButton.layer.borderWidth = 2
        enterpriseButton.layer.borderColor = SLColor.tintColor.cgColor
    }
    
    private func buy(_ product: SKProduct) {
        MBProgressHUD.showAdded(to: view, animated: true)
        SwiftyStoreKit.purchaseProduct(product.productIdentifier) { [weak self] (result) in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.view, animated: true)
            
            switch result {
            case .success(let purchase):
                Toast.displayShortly(message: "Purchase successful")
                
            case .error(let error):
                switch error.code {
                case .unknown:
                    Toast.displayShortly(message: "Unknown error")
                    
                case .clientInvalid:
                    Toast.displayShortly(message: "Invalid client")
                    
                case .paymentCancelled: break
                    
                case .paymentInvalid:
                    Toast.displayShortly(message: "Invalid payment")
                    
                case .paymentNotAllowed:
                    Toast.displayShortly(message: "Payment not allowed")
                    
                case .storeProductNotAvailable:
                    Toast.displayShortly(message: "Product is not available")
                    
                case .cloudServicePermissionDenied:
                    Toast.displayShortly(message: "Cloud service permission denied")
                    
                case .cloudServiceNetworkConnectionFailed:
                    Toast.displayShortly(message: "Cloud service network connection failed")
                    
                case .cloudServiceRevoked:
                    Toast.displayShortly(message: "Cloud service revoked")
                    
                default:
                    Toast.displayShortly(message: "Error: \((error as NSError).localizedDescription)")
                }
            }
        }
    }
    
    private func fetchProducts() {
        MBProgressHUD.showAdded(to: view, animated: true)
        rootScrollView.isHidden = true
        
        SwiftyStoreKit.retrieveProductsInfo(Set([IapProduct.monthly.productId, IapProduct.yearly.productId])) { [weak self] (results) in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.view, animated: true)
            self.rootScrollView.isHidden = false
            
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

        monthlyButton.setTitle("Monthly subscription \(productMonthly.regularPrice ?? "")/month", for: .normal)
        yearlyButton.setTitle("Yearly subscription \(productYearly.regularPrice ?? "")/year", for: .normal)
    }
    
    private func fetchReceipt() {
        SwiftyStoreKit.fetchReceipt(forceRefresh: true) { result in
            switch result {
            case .success(let receiptData):
                let encryptedReceipt = receiptData.base64EncodedString(options: [])
                Toast.displayShortly(message: "Fetch receipt success:\n\(encryptedReceipt)")
                UIPasteboard.general.string = encryptedReceipt
            case .error(let error):
                Toast.displayShortly(message: "Fetch receipt failed: \(error)")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let webViewController as WebViewController:
            
            switch segue.identifier {
            case "showTerms": webViewController.module = .terms
            case "showPrivacy": webViewController.module = .privacy
            default: return
            }
            
        default: return
        }
    }
}

// MARK: - IBActions
extension IapViewController {
    @IBAction private func yearlyButtonTapped() {
        selectedIapProduct = .yearly
    }
    
    @IBAction private func monthlyButtonTapped() {
        selectedIapProduct = .monthly
    }
    
    @IBAction private func upgradeButtonTapped() {
        
    }
    
    @IBAction private func enterpriseButtonTapped() {
        performSegue(withIdentifier: "showEnterprise", sender: nil)
    }
    
    @IBAction private func termsButtonTapped() {
        performSegue(withIdentifier: "showTerms", sender: nil)
    }
    
    @IBAction private func privacyButtonTapped() {
        performSegue(withIdentifier: "showPrivacy", sender: nil)
    }
}
