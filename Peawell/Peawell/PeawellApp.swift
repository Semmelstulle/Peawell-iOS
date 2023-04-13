//
//  PeawellApp.swift
//  Peawell
//
//  Created by Dennis on 11.04.23.
//

import SwiftUI
import CoreHaptics

@main
struct PeawellApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

func hapticWarning() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.warning)
}
