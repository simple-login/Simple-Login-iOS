//
//  StepTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 16/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class StepTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var stepTitleLabel: UILabel!
    @IBOutlet private weak var stepImageView: UIImageView!
    @IBOutlet private weak var stepDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func bind(with step: Step) {
        stepTitleLabel.text = step.title
        stepImageView.image = UIImage(named: step.imageName)
        stepDescriptionLabel.text = step.description
    }
}
