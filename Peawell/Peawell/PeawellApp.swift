//
//  PeawellApp.swift
//  Peawell
//
//  Created by Dennis on 11.04.23.
//

import SwiftUI
import CoreHaptics

//  constants stored on the top
let mainTitle: String = "Peawell"
let addTitle: String = "Add entry"
let settingsTitle: String = "Settings"

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
