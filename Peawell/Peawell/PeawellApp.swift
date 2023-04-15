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
func saveMeds() {
    @Environment(\.managedObjectContext) var viewContext

    @State var medName: String = ""
    @State var medAmount: String = ""
    
    let context = viewContext
    let meds = Meds(context: context)
    meds.medType = medName
    meds.medDose = medAmount
    do {
        try context.save()
        hapticConfirm()
    } catch {
        let saveMedError = error as NSError
        fatalError("Fatal error \(saveMedError), \(saveMedError.userInfo) while saving")
    }
}

func saveMood() {
    @Environment(\.managedObjectContext) var viewContext

    @State var actName: String = ""
    @State var moodName: String = ""

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

    @Environment(\.managedObjectContext) var viewContext

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Mood.moodName, ascending: true)], animation: .default)
    var moodItems: FetchedResults<Mood>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Meds.medType, ascending: true)], animation: .default)
    var medsItems: FetchedResults<Meds>

    for object in medsItems {
        viewContext.delete(object)
    }
    for object in moodItems {
        viewContext.delete(object)
    }
    try? viewContext.save()
}


// functions to get data
func fetchMood() -> [NSManagedObject] {
    @Environment(\.managedObjectContext) var viewContext

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
    @Environment(\.managedObjectContext) var viewContext

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
