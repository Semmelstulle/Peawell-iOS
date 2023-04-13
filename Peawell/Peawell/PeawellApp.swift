//
//  PeawellApp.swift
//  Peawell
//
//  Created by Dennis on 11.04.23.
//

import SwiftUI
import CoreHaptics
import CoreData

//  constants stored on the top
let mainTitle: String = "Peawell"
let addTitle: String = "Add entry"
let settingsTitle: String = "Settings"

@main
struct PeawellApp: App {
    
    //  sets up CoreData part 1
    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                //  sets up CoreData part 2
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

//  vibration patterns called from CoreHaptics to use in SwiftUI
func hapticWarning() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.warning)
}
func hapticConfirm() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.success)
}

//  function to safe added content to CoreData
func safeMeds() {
    
}
func safeMood() {
    
}
