//
//  RippleView.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 03/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialRipple

class RippleView: UIView {
    private var rippleView: MDCRippleView!
    
    var didTap: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        rippleView = MDCRippleView()
        rippleView.rippleColor = UIColor.white.withAlphaComponent(0.2)
        addSubview(rippleView)
        rippleView.fillSuperview()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let touchPoint = touch.location(in: self)
        rippleView.beginRippleTouchDown(at: touchPoint, animated: true, completion: nil)
        rippleView.beginRippleTouchUp(animated: true, completion: nil)
        didTap?()
    }
}
