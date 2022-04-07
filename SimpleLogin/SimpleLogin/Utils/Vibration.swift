//
//  Vibration.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 16/01/2022.
//

import AVFoundation
import CoreHaptics
import SwiftUI
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

    @AppStorage(kHapticFeedbackEnabled) private static var hapticFeedbackEnabled = true

    func vibrate(fallBackToOldSchool: Bool = false) {
        guard Self.hapticFeedbackEnabled else { return }
        if fallBackToOldSchool && !CHHapticEngine.capabilitiesForHardware().supportsHaptics {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            return
        }
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
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        case .rigid:
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        case .oldSchool:
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
}
