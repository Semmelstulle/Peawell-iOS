//
//  HapticFeedback.swift
//  Peawell
//
//  Created by Dennis on 25.05.25.
//

import CoreHaptics
import UIKit

// Haptic feedback utility functions

func hapticWarning() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.warning)
}

func hapticConfirm() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.success)
}
