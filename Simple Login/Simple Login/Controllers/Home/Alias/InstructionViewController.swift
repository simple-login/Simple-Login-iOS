//
//  InstructionViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 04/04/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Gifu
import UIKit

final class InstructionViewController: BaseViewController, Storyboarded {
    @IBOutlet private weak var deleteImageView: GIFImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        deleteImageView.animate(withGIFNamed: "delete")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Settings.shared.showedDeleteAndRandomAliasInstruction = true
    }

    @IBAction private func gotItButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
