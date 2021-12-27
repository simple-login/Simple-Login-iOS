//
//  AlertToastExtensions.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 18/11/2021.
//

import AlertToast

extension AlertToast {
    static func errorAlert(message: String?) -> AlertToast {
        AlertToast(displayMode: .banner(.pop),
                   type: .error(.red),
                   title: message)
    }

    static func messageAlert(message: String?) -> AlertToast {
        AlertToast(displayMode: .banner(.pop),
                   type: .regular,
                   title: message)
    }
}
