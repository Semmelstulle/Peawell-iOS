//
//  PeawellApp.swift
//  Peawell
//
//  Created by Dennis on 11.04.23.
//

import SwiftUI
import CoreData

//  defines entry point and sets it up
@main
struct PeawellApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            MainView()
                .accentColor(Color(UIColor(named: selectedAccentColor) ?? .green))
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    //  adds UserData to local scope
    @AppStorage("selectedAccentColor") private var selectedAccentColor: String = "AccentColor"
    @AppStorage("resetOnLaunch") var resetOnLaunch = false
    init() {
        if self.resetOnLaunch == true {
            //  resets toggle and calls reset function
            UserDefaults.standard .set(false, forKey: "resetOnLaunch")
            resetData()
        }
    }
}
