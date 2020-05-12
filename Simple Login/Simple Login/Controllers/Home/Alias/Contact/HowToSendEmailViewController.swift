//
//  HowToSendEmailViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 13/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import FirebaseAnalytics

final class HowToSendEmailViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        Analytics.logEvent("open_how_to_send_email_view_controller", parameters: nil)
    }
    
    @IBAction private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
