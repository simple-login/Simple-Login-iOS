//
//  DeletedAliasTableViewCell.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 26/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class DeletedAliasTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var deletionDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = UITableViewCell.SelectionStyle.none
    }
    
    func bind(with deletedAlias: DeletedAlias) {
        nameLabel.text = deletedAlias.email
        deletionDateLabel.text = deletedAlias.deletionTimestampString
    }
}
