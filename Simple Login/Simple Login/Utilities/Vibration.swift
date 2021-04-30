//
//  Vibration.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 22/04/2021.
//  Copyright © 2021 SimpleLogin. All rights reserved.
//

import AVFoundation
import UIKit

enum Vibration {
    case error
    case success
    case warning
    case light
    case medium
    case heavy
    case soft
    case rigid
    case selection
    case oldSchool

    func vibrate() {
        switch self {
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .soft:
            if #available(iOS 13.0, *) {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            } else {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        case .rigid:
            if #available(iOS 13.0, *) {
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            } else {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        case .oldSchool:
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
}
