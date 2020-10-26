//
//  WalkthroughNoExtraMailViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 25/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Gifu
import UIKit

final class WalkthroughNoExtraMailViewController: BaseWalkthroughStepViewController {
    @IBOutlet private weak var imageView: GIFImageView!

    override var index: Int { 1 }

    deinit {
        print("WalkthroughNoExtraMailViewController is deallocated")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.animate(withGIFNamed: "superman")
    }
}
