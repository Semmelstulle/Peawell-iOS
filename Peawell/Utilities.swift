//
//  Utilities.swift
//  Peawell
//
//  Created by Dennis on 25.05.25.
//

import Foundation
import SwiftUI
import CoreData
import UniformTypeIdentifiers

// Utility function to delete an item by its NSManagedObjectID
func trashItem(objectID: NSManagedObjectID) {
    let viewContext = PersistenceController.shared.container.viewContext
    if let object = try? viewContext.existingObject(with: objectID) {
        viewContext.delete(object)
        do {
            try viewContext.save()
        } catch {
            NSLog("Error deleting object: \(error.localizedDescription)")
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

func saveMedsWithSchedules(
    med: Meds?,
    medName: String,
    medAmount: String,
    medUnit: String,
    medKind: String,
    medRemind: Bool,
    schedules: [MedSchedule]
) {
    let viewContext = PersistenceController.shared.container.viewContext

    // Use existing med or create new
    let medObject = med ?? Meds(context: viewContext)

    medObject.medType = medName
    medObject.medDose = medAmount
    medObject.medUnit = medUnit
    medObject.medKind = medKind
    medObject.medRemind = medRemind

    // Clear existing schedules
    if let existingSchedules = medObject.schedule as? Set<Schedules> {
        existingSchedules.forEach { viewContext.delete($0) }
    }

    // Only add schedules if reminders are enabled
    if medRemind {
        for scheduleData in schedules {
            // Skip empty schedules
            guard !scheduleData.days.isEmpty, !scheduleData.times.isEmpty else { continue }

            let schedule = Schedules(context: viewContext)
            schedule.dates = scheduleData.days as NSSet
            schedule.times = scheduleData.times as NSSet
            medObject.addToSchedule(schedule)
        }
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
func saveMood(actName: String, moodName: String, moodLogDate: Date, selectedCategories: [MoodCategory]) {
    let viewContext = PersistenceController.shared.container.viewContext
    let mood = Mood(context: viewContext)
    
    mood.activityName = actName
    mood.moodName = moodName
    mood.logDate = moodLogDate

    // Remove existing categories if any (optional)
    if let existingCategories = mood.childCategories as? Set<MoodCategories> {
        for category in existingCategories {
            mood.removeFromChildCategories(category)
        }
    }

    for category in selectedCategories {
        // Fetch or create MoodCategories by name
        let fetchRequest: NSFetchRequest<MoodCategories> = MoodCategories.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", category.name)
        
        if let existingCategory = try? viewContext.fetch(fetchRequest).first {
            mood.addToChildCategories(existingCategory)
        } else {
            let newCategory = MoodCategories(context: viewContext)
            newCategory.name = category.name
            newCategory.sfsymbol = category.sfsymbol
            mood.addToChildCategories(newCategory)
        }
    }
    
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
    // Clear all UserDefaults keys for your app
    if let appDomain = Bundle.main.bundleIdentifier {
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
        UserDefaults.standard.synchronize()
    }
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

//  resets all data to empty and settings to their default
func resetUserData() {
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



func createDummyData(context: NSManagedObjectContext, amount: Int) throws {
    // Predefined sample data for meds
    let medKinds = ["longPill", "roundPill", "drops", "inhaler", "drops"]
    let medTypes = ["Medication 1", "Daily pill", "Eyedrops", "Inhale stuff", "Insanely long name for a medication to test edge cases"]
    let medUnits = ["mg", "µg", "ml", "mg", "ml"]
    // Predefined sample data for meds
    let activityNames = ["Running", "Reading", "Meditating", "Cooking", "Sleeping", "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.","Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."]
    let moodNames = ["Awesome", "Good", "Horrible", "Neutral", "Bad", "Good", "Good"]

    // Helper function to generate a random date within the last year
    func randomDateWithinLastYear() -> Date {
        let secondsInYear: TimeInterval = 365 * 24 * 60 * 60
        let randomTimeAgo = TimeInterval.random(in: 0...secondsInYear)
        return Date().addingTimeInterval(-randomTimeAgo)
    }

    // Create 100 Mood entities
    for _ in 0..<amount {
        let mood = Mood(context: context)
        mood.moodName = moodNames.randomElement()
        mood.activityName = activityNames.randomElement()
        mood.logDate = randomDateWithinLastYear()
    }

    // Create 100 Meds entities
    for _ in 0..<amount {
        let med = Meds(context: context)
        med.medKind = medKinds.randomElement()
        med.medType = medTypes.randomElement()
        med.medDose = String(format: "%.1f", Double.random(in: 1...500))
        med.medUnit = medUnits.randomElement()
        med.medRemind = Bool.random()
    }

    // Save the context to persist data
    if context.hasChanges {
        try context.save()
    }
}

// functions to get data
func fetchMood() -> [NSManagedObject] {
    //  add CoreData to scope
    let viewContext = PersistenceController.shared.container.viewContext
    //  prepares data as arr
    var fetchedArray: [NSManagedObject] = []
    let fetchRequest: NSFetchRequest<Mood> = Mood.fetchRequest()
    fetchRequest.fetchBatchSize = 20
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
    fetchRequest.fetchBatchSize = 20
    do {
        var results: [Meds]
        results = try viewContext.fetch(fetchRequest)
        fetchedArray = results as [NSManagedObject]
    } catch {
        NSLog(error.localizedDescription)
    }
    return fetchedArray
}

func deleteMood() {
    let viewContext = PersistenceController.shared.container.viewContext
    
    // runs fetch functions to gather all data and delete them
    for object in fetchMood() {
        viewContext.delete(object)
    }
    try? viewContext.save()
}

func saveEdits() {
    let viewContext = PersistenceController.shared.container.viewContext
    
    // saves the context it recieves
    try? viewContext.save()
}

//  prepares colors
var bgColorHorrible: Color = Color.red
var bgColorBad: Color = Color.orange
var bgColorNeutral: Color = Color.yellow
var bgColorGood: Color = Color.green
var bgColorAwesome: Color = Color.mint

//  prepares the color variables for the diary entries in the list view
func getMoodColor(_ moodName: String?) -> Color {
    switch moodName {
    case "Horrible":
        return bgColorHorrible
    case "Bad":
        return bgColorBad
    case "Neutral":
        return bgColorNeutral
    case "Good":
        return bgColorGood
    case "Awesome":
        return bgColorAwesome
    default:
        return bgColorNeutral
    }
}

// MARK: - Import Export logic

struct ExportData: Codable {
    let appVersion: String
    let moods: [MoodStruct]
    let meds: [MedStruct]
}

struct MoodStruct: Codable {
    let activityName: String
    let moodName: String
    let logDate: Date
    let categories: [MoodCategoryStruct]  // New field
}

struct MoodCategoryStruct: Codable {
    let name: String
    let sfsymbol: String?
}

struct MedStruct: Codable {
    let medType: String
    let medDose: String
    let medUnit: String
    let medKind: String
    let medRemind: Bool
    let schedules: [ScheduleStruct]
    let logTimes: [LogTimeMedStruct]
}

struct ScheduleStruct: Codable {
    let dates: [Date]
    let times: [Date]
}

struct LogTimeMedStruct: Codable {
    let logTime: Date
}

// Export user data as JSON
func exportUserData() -> URL? {
    _ = PersistenceController.shared.container.viewContext

    // Existing mood fetch
    let moods = fetchMood().compactMap { mood -> MoodStruct? in
        guard let m = mood as? Mood,
              let actName = m.activityName,
              let moodName = m.moodName,
              let logDate = m.logDate else { return nil }

        // Export all associated categories for this mood
        let categories: [MoodCategoryStruct] = (m.childCategories as? Set<MoodCategories>)?.map { cat in
            MoodCategoryStruct(name: cat.name ?? "", sfsymbol: cat.sfsymbol)
        } ?? []

        return MoodStruct(activityName: actName, moodName: moodName, logDate: logDate, categories: categories)
    }

    // Fetch meds with schedules and log times
    let meds = fetchMeds().compactMap { med -> MedStruct? in
        guard let m = med as? Meds else { return nil }

        // Map schedules
        let schedules = (m.schedule as? Set<Schedules>)?.compactMap { sched -> ScheduleStruct? in
            // Convert NSSet -> [Date]
            let dateArray = (sched.dates as? Set<Date>)?.sorted() ?? []
            let timeArray = (sched.times as? Set<Date>)?.sorted() ?? []
            return ScheduleStruct(dates: dateArray, times: timeArray)
        } ?? []

        // Map logTimes
        let logTimes = (m.logTimes as? Set<LogTimeMeds>)?.compactMap { logTimeMed -> LogTimeMedStruct? in
            guard let time = logTimeMed.logTimes else { return nil }
            return LogTimeMedStruct(logTime: time)
        } ?? []

        return MedStruct(
            medType: m.medType ?? "",
            medDose: m.medDose ?? "",
            medUnit: m.medUnit ?? "",
            medKind: m.medKind ?? "",
            medRemind: m.medRemind,
            schedules: schedules,
            logTimes: logTimes
        )
    }

    let appVer = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"

    let exportData = ExportData(appVersion: appVer, moods: moods, meds: meds)

    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    do {
        let data = try encoder.encode(exportData)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("PeawellExport.json")
        try data.write(to: tempURL)
        return tempURL
    } catch {
        NSLog("Failed to encode/export user data: \(error.localizedDescription)")
        return nil
    }
}

// Import user data from JSON
func importUserData(from url: URL) -> Bool {
    let viewContext = PersistenceController.shared.container.viewContext

    do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let importData = try decoder.decode(ExportData.self, from: data)

        // Optional: Clear existing data (adjust as needed)
        let fetchMedsRequest: NSFetchRequest<NSFetchRequestResult> = Meds.fetchRequest()
        let batchDeleteMeds = NSBatchDeleteRequest(fetchRequest: fetchMedsRequest)
        try viewContext.execute(batchDeleteMeds)
        
        let fetchSchedulesRequest: NSFetchRequest<NSFetchRequestResult> = Schedules.fetchRequest()
        let batchDeleteSchedules = NSBatchDeleteRequest(fetchRequest: fetchSchedulesRequest)
        try viewContext.execute(batchDeleteSchedules)
        
        let fetchLogTimesRequest: NSFetchRequest<NSFetchRequestResult> = LogTimeMeds.fetchRequest()
        let batchDeleteLogTimes = NSBatchDeleteRequest(fetchRequest: fetchLogTimesRequest)
        try viewContext.execute(batchDeleteLogTimes)

        let fetchMoodsRequest: NSFetchRequest<NSFetchRequestResult> = Mood.fetchRequest()
        let batchDeleteMoods = NSBatchDeleteRequest(fetchRequest: fetchMoodsRequest)
        try viewContext.execute(batchDeleteMoods)

        // Import moods
        for moodStruct in importData.moods {
            let mood = Mood(context: viewContext)
            mood.activityName = moodStruct.activityName
            mood.moodName = moodStruct.moodName
            mood.logDate = moodStruct.logDate

            for categoryStruct in moodStruct.categories {
                // Try fetching existing category to avoid duplicates
                let fetchRequest: NSFetchRequest<MoodCategories> = MoodCategories.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "name == %@", categoryStruct.name)

                if let existingCategory = try? viewContext.fetch(fetchRequest).first {
                    mood.addToChildCategories(existingCategory)
                } else {
                    let newCategory = MoodCategories(context: viewContext)
                    newCategory.name = categoryStruct.name
                    newCategory.sfsymbol = categoryStruct.sfsymbol
                    mood.addToChildCategories(newCategory)
                }
            }
        }

        // Import meds with schedules and log times
        for medStruct in importData.meds {
            let med = Meds(context: viewContext)
            med.medType = medStruct.medType
            med.medDose = medStruct.medDose
            med.medUnit = medStruct.medUnit
            med.medKind = medStruct.medKind
            med.medRemind = medStruct.medRemind

            // Schedules
            for scheduleStruct in medStruct.schedules {
                let schedule = Schedules(context: viewContext)
                // Assign NSSet from arrays
                schedule.dates = NSSet(array: scheduleStruct.dates)
                schedule.times = NSSet(array: scheduleStruct.times)
                schedule.medication = med
            }

            // Log Times
            for logTimeStruct in medStruct.logTimes {
                let logTimeMed = LogTimeMeds(context: viewContext)
                logTimeMed.logTimes = logTimeStruct.logTime
                logTimeMed.medication = med
            }
        }

        try viewContext.save()
        return true
    } catch {
        NSLog("Failed to import user data: \(error)")
        return false
    }
}

struct URLDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var url: URL

    init(url: URL) {
        self.url = url
    }

    init(configuration: ReadConfiguration) throws {
        fatalError("Not implemented")
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return try FileWrapper(url: url, options: .withoutMapping)
    }
}

