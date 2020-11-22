//
//  AvatarImageView.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 16/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Toaster
import UIKit

class AvatarImageView: UIImageView {
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpUI()
    }

    private func setUpUI() {
        layer.cornerRadius = bounds.width / 2
        layer.borderWidth = 2
        layer.borderColor = SLColor.tintColor.cgColor
        layer.backgroundColor = SLColor.tintColor.withAlphaComponent(0.5).cgColor
    }

    func setImage(with urlString: String?) {
        guard let urlString = urlString else { return }
        ImageService.shared.getImage(from: urlString) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.image = UIImage(data: data)
                    self.layer.borderColor = UIColor.clear.cgColor

                case .failure(let error):
                    Toast.displayLongly(message: error.description)
                    self.layer.borderColor = SLColor.tintColor.cgColor
                }
            }
        }
    }
}
