//
//  PersistenceController.swift
//  Peawell
//
//  Created by Dennis on 13.04.23.
//

import Foundation
import CoreData

struct PersistenceController {
    //  singleton for our entire app to use
    static let shared = PersistenceController()
    // Storage for Core Data
    let container: NSPersistentContainer
    //  test configuration for SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        //  dummy data for previews
        let medKinds = ["longPill", "roundPill", "drops", "inhaler"]
        let medDoses = ["420", "69", "360", "21"]
        let medTypes = ["Medication 1", "Daily pill", "Eyedrops", "Inhale stuff"]
        let medUnits = ["mg", "µg", "ml", "mg"]
        var meds: [Meds] = []
        for i in 0..<medKinds.count {
            let newMed = Meds(context: viewContext)
            newMed.medKind = medKinds[i]
            newMed.medDose = medDoses[i]
            newMed.medType = medTypes[i]
            newMed.medUnit = medUnits[i]
            meds.append(newMed)
        }
        let activityNames = ["Running", "Reading", "Meditating", "Cooking", "Sleeping"]
        let moodNames = ["Awesome", "Good", "Horrible", "Neutral", "Bad"]
        let logDates: [Date] = [
            Date(),
            Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            Calendar.current.date(byAdding: .day, value: -4, to: Date())!,
            Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        ]
        for i in 0..<activityNames.count {
            let newMood = Mood(context: viewContext)
            newMood.activityName = activityNames[i]
            newMood.moodName = moodNames[i]
            newMood.logDate = logDates[i]
        }
        // Add dummy LogTimeMeds entries for MedLogView preview
        for (i, med) in meds.enumerated() {
            let log = LogTimeMeds(context: viewContext)
            log.medication = med
            log.logTimes = Calendar.current.date(byAdding: .hour, value: -i * 3, to: Date())
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return controller
    }()
    // An initializer to load Core Data, optionally able to use an in-memory store.
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Main")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores {description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Show some error here
            }
        }
    }
}
