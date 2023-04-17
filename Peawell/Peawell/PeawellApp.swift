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
    //@Environment(\.scenePhase) var scenePhase

    
    var body: some Scene {
        WindowGroup {
            TabBarView()
            //  sets up CoreData part 2
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }

    @AppStorage("resetOnLaunch") var resetOnLaunch = false
    init() {
        if self.resetOnLaunch == true {
            UserDefaults.standard .set(false, forKey: "resetOnLaunch")
            resetData()
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
func saveMeds(medName: String, medAmount: String) {
    let viewContext = PersistenceController.shared.container.viewContext
    let meds = Meds(context: viewContext)
    meds.medType = medName
    meds.medDose = medAmount
    do {
        try viewContext.save()
        hapticConfirm()
    } catch {
        let saveMedError = error as NSError
        fatalError("Fatal error \(saveMedError), \(saveMedError.userInfo) while saving")
    }
}

func saveMood(actName: String, moodName: String) {
    let viewContext = PersistenceController.shared.container.viewContext
    let context = viewContext
    let mood = Mood(context: context)
    mood.activityName = actName
    mood.moodName = moodName
    do {
        try context.save()
        hapticConfirm()
    } catch {
        let saveMedError = error as NSError
        fatalError("Fatal error \(saveMedError), \(saveMedError.userInfo) while saving")
    }
}


// resets all data to empty and settings to their default
func resetData() {
    UserDefaults.standard.set(true, forKey: "settingShowMoodSection")
    UserDefaults.standard.set(true, forKey: "settingShowMedicationSection")
    UserDefaults.standard.set(false, forKey: "settingSynciCloud")
    UserDefaults.standard.set(false, forKey: "settingSyncCalendar")

    let viewContext = PersistenceController.shared.container.viewContext

    for object in fetchMood() {
        viewContext.delete(object)
    }
    for object in fetchMeds() {
        viewContext.delete(object)
    }
    try? viewContext.save()
}

func trashMeds(objectID: NSManagedObjectID) {
    let viewContext = PersistenceController.shared.container.viewContext
    withAnimation {
        do {
            if let object = try? viewContext.existingObject(with: objectID) {
                viewContext.delete(object)
            }
            try viewContext.save()
        } catch {
            NSLog(error.localizedDescription)
        }
    }
}


// functions to get data
func fetchMood() -> [NSManagedObject] {
    let viewContext = PersistenceController.shared.container.viewContext

    var fetchedArray: [NSManagedObject] = []

    let fetchRequest: NSFetchRequest<Mood> = Mood.fetchRequest()
    do {
        var results: [Mood]
        results = try viewContext.fetch(fetchRequest)
        fetchedArray = results as [NSManagedObject]
    } catch {
        NSLog(error.localizedDescription)
    }
    return fetchedArray
}


func fetchMeds() -> [NSManagedObject] {
    let viewContext = PersistenceController.shared.container.viewContext

    var fetchedArray: [NSManagedObject] = []

    let fetchRequest: NSFetchRequest<Meds> = Meds.fetchRequest()
    do {
        var results: [Meds]
        results = try viewContext.fetch(fetchRequest)
        fetchedArray = results as [NSManagedObject]
    } catch {
        NSLog(error.localizedDescription)
    }
    return fetchedArray
}


// empty function
func emptyFunc() {
    print("emptyFunc called")
}
