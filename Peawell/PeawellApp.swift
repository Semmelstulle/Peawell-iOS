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

//  function to safe added content to CoreData
func saveMedsWithSchedule(
    med: Meds?,
    medName: String,
    medAmount: String,
    medUnit: String,
    medKind: String,
    medRemind: Bool,
    selectedDays: Set<Int>,
    selectedTimes: Set<Date>
) {
    let viewContext = PersistenceController.shared.container.viewContext
    
    //  use existing med or create new
    let medObject = med ?? Meds(context: viewContext)
    
    medObject.medType = medName
    medObject.medDose = medAmount
    medObject.medUnit = medUnit
    medObject.medKind = medKind
    medObject.medRemind = medRemind
    
    //  clear existing schedules
    if let existingSchedules = medObject.schedule as? Set<Schedules> {
        existingSchedules.forEach { viewContext.delete($0) }
    }
    if medRemind && !selectedDays.isEmpty && !selectedTimes.isEmpty {
        let schedule = Schedules(context: viewContext)
        schedule.dates = selectedDays as NSSet
        schedule.times = selectedTimes as NSSet
        medObject.addToSchedule(schedule)
    }
    do {
        try viewContext.save()
        hapticConfirm()
    } catch {
        let saveMedError = error as NSError
        fatalError("Fatal error \(saveMedError), \(saveMedError.userInfo)")
    }
}

//  saves the mood and diary entry
func saveMood(actName: String, moodName: String, moodLogDate: Date) {
    //  needed to add CoreData into scope
    let viewContext = PersistenceController.shared.container.viewContext
    let mood = Mood(context: viewContext)
    //  maps CoreData values to variables
    mood.activityName = actName
    mood.moodName = moodName
    mood.logDate = moodLogDate
    do {
        try viewContext.save()
        hapticConfirm()
    } catch {
        let saveMedError = error as NSError
        fatalError("Fatal error \(saveMedError), \(saveMedError.userInfo) while saving")
    }
}

//  resets all data to empty and settings to their default
func resetData() {

    //  sets UserData to default values (NOT a real reset by deletion!)
    UserDefaults.standard.set(true, forKey: "settingShowMoodSection")
    UserDefaults.standard.set(true, forKey: "settingShowMedicationSection")
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
