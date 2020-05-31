//
//  BaseViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 11/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    deinit {
        printIfDebug("\(Self.self) is deallocated")
    }
}
