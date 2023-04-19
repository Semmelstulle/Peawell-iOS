//
//  PeawellApp.swift
//  Peawell
//
//  Created by Dennis on 11.04.23.
//

import SwiftUI
import CoreHaptics
import CoreData

//  the whole logic lives here

//  needs to piggyback on UIKit to get system colours
extension Color {
    static let secondarySystemBackground =
    Color(uiColor: .secondarySystemBackground)
    static let tertiarySystemBackground =
    Color(uiColor: .tertiarySystemBackground)
}

//  constants stored on the top
let mainTitle: String = "Peawell"
let overviewTitle: String = "Overview"
let settingsTitle: String = "Settings"


@main
struct PeawellApp: App {
    //  sets up CoreData part 1
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            //  initial view that is used on app launch
            TabBarView()
            //  sets up CoreData part 2
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    
    //  adds UserData to local scope
    @AppStorage("resetOnLaunch") var resetOnLaunch = false
    init() {
        if self.resetOnLaunch == true {
            //  resets toggle and calls reset function
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
func saveMeds(medName: String, medAmount: String, medUnit: String) {
    //  needed to add CoreData into scope
    let viewContext = PersistenceController.shared.container.viewContext
    let meds = Meds(context: viewContext)
    //  maps CoreData values to variables
    meds.medType = medName
    meds.medDose = medAmount
    meds.medUnit = medUnit
    do {
        try viewContext.save()
        hapticConfirm()
    } catch {
        let saveMedError = error as NSError
        fatalError("Fatal error \(saveMedError), \(saveMedError.userInfo) while saving")
    }
}

func saveMood(actName: String, moodName: String) {
    //  needed to add CoreData into scope
    let viewContext = PersistenceController.shared.container.viewContext
    let mood = Mood(context: viewContext)
    //  maps CoreData values to variables
    mood.activityName = actName
    mood.moodName = moodName
    do {
        try viewContext.save()
        hapticConfirm()
    } catch {
        let saveMedError = error as NSError
        fatalError("Fatal error \(saveMedError), \(saveMedError.userInfo) while saving")
    }
}


// resets all data to empty and settings to their default
func resetData() {
    //  sets UserData to default values (NOT a real reset by deletion!)
    UserDefaults.standard.set(true, forKey: "settingShowMoodSection")
    UserDefaults.standard.set(true, forKey: "settingShowMedicationSection")
    UserDefaults.standard.set(false, forKey: "settingSynciCloud")
    UserDefaults.standard.set(false, forKey: "settingSyncCalendar")
    
    //  add CoreData to scope
    let viewContext = PersistenceController.shared.container.viewContext
    
    //  runs fetch functions to gather all data and delete them
    for object in fetchMood() {
        viewContext.delete(object)
    }
    for object in fetchMeds() {
        viewContext.delete(object)
    }
    try? viewContext.save()
}


//  functions to delete specific items
func trashMeds(objectID: NSManagedObjectID) {
    //  add CoreData to scope
    let viewContext = PersistenceController.shared.container.viewContext
    withAnimation {
        do {
            //  checks if object exists and tries to delete if so
            if let object = try? viewContext.existingObject(with: objectID) {
                viewContext.delete(object)
            }
            try viewContext.save()
            hapticConfirm()
        } catch {
            NSLog(error.localizedDescription)
        }
    }
}


// functions to get data
func fetchMood() -> [NSManagedObject] {
    //  add CoreData to scope
    let viewContext = PersistenceController.shared.container.viewContext
    
    //  prepares data as arr
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
    //  add CoreData to scope
    let viewContext = PersistenceController.shared.container.viewContext
    
    //  prepares data as arr
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
