//
//  MoodLogView.swift
//  Peawell
//
//  Created by Dennis on 12.04.23.
//

import SwiftUI
import CoreData

struct MoodLogView: View {
    // fetched data
    @Environment(\.managedObjectContext) private var viewContext
    @State private var moodItems: [Mood] = []

    @State private var showingDeleteAlert = false
    
    @State private var searchText: String = ""
    
    // NEW: editing state
    @State private var editingMood: Mood?
    @State private var isEditingSheetPresented = false

    var body: some View {
        List {
            ForEach(moodItems) { item in
                NavigationLink {
                    detailedJournal(for: item)
                } label: {
                    allJournals(for: item)
                }
                .swipeActions(allowsFullSwipe: true) {
                    deleteButton(for: item)
                    editButton(for: item)
                }
            }
        }
        .onAppear {
            fetchMoods()
        }
        .onChange(of: searchText) { _ in
            fetchMoods()
        }
        .searchable(text: $searchText, prompt: "search.moods")
        .navigationTitle("title.diary")
        .sheet(item: $editingMood) { moodToEdit in
            MoodPickerView(
                moodName: moodToEdit.moodName ?? "",
                actName: moodToEdit.activityName ?? "",
                moodLogDate: moodToEdit.logDate ?? Date(),
                selectedCategories: Set(Array(moodToEdit.childCategories as? Set<MoodCategories> ?? []).map {
                    MoodCategory(name: $0.name ?? "", sfsymbol: $0.sfsymbol)
                }),
                onSave: { newActName, newMoodName, newLogDate, newCategories in
                    // Update fields in CoreData, similar to saveMood edit logic
                    moodToEdit.activityName = newActName
                    moodToEdit.moodName = newMoodName
                    moodToEdit.logDate = newLogDate
                    // Remove old categories
                    if let existingCategories = moodToEdit.childCategories as? Set<MoodCategories> {
                        for category in existingCategories {
                            moodToEdit.removeFromChildCategories(category)
                        }
                    }
                    // Add new categories
                    let context = PersistenceController.shared.container.viewContext
                    for category in newCategories {
                        let fetchRequest: NSFetchRequest<MoodCategories> = MoodCategories.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "name == %@", category.name)
                        if let existingCategory = try? context.fetch(fetchRequest).first {
                            moodToEdit.addToChildCategories(existingCategory)
                        } else {
                            let newCategory = MoodCategories(context: context)
                            newCategory.name = category.name
                            newCategory.sfsymbol = category.sfsymbol
                            moodToEdit.addToChildCategories(newCategory)
                        }
                    }
                    try? context.save()
                    isEditingSheetPresented = false
                },
                onDismiss: {
                    isEditingSheetPresented = false
                }
            )
        }
    }
    
    @ViewBuilder
    func allJournals(for item: Mood) -> some View {
        HStack {
            Image("mood\(item.moodName ?? "Neutral")")
                .resizable()
                .frame(width: 20, height: 20)
                .padding(6)
                .background(getMoodColor(item.moodName))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            Text(item.logDate ?? Date.now, style: .date)
        }
    }
    
    @ViewBuilder
    func detailedJournal(for item: Mood) -> some View {
        List {
            Section {
                HStack {
                    Spacer()
                    Image("mood\(item.moodName ?? "Neutral")")
                    Spacer()
                }
            }
            .listRowBackground(getMoodColor(item.moodName))
            if (item.childCategories != []) {
                Section {
                    FlowLayout {
                        ForEach(Array(item.childCategories as? Set<MoodCategories> ?? [])) { category in
                            ChipView(
                                category: MoodCategory(
                                    name: category.name ?? "",
                                    sfsymbol: category.sfsymbol
                                ),
                                isSelected: false,
                                onTap: {}
                            )
                        }
                    }
                    .padding(-16)
                }
                .listRowBackground(Color.clear)
            }
            Section {
                Text(item.activityName ?? "Text missing")
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .toolbar {
            editButton(for: item)
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Image(systemName: "trash")
            }
            .confirmationDialog("", isPresented: $showingDeleteAlert) {
                Button("button.dialog.cancelReset", role: .cancel) {
                    showingDeleteAlert = false
                }
                Button("button.dialog.confirmReset", role: .destructive) {
                    trashItem(objectID: item.objectID)
                }
            }
        }
        .navigationTitle(Text(item.logDate ?? Date.now, style: .date))
    }
    
    private func editButton(for item: Mood) -> some View {
        Button {
            editingMood = item
            isEditingSheetPresented = true
        } label: {
            Image(systemName: "square.and.pencil")
        }
    }
    
    private func deleteButton(for item: Mood) -> some View {
        Button(role: .destructive) {
            trashItem(objectID: item.objectID)
        } label: {
            Image(systemName: "trash")
        }
    }
    
    func fetchMoods() {
        let request: NSFetchRequest<Mood> = Mood.fetchRequest()
        // Sorting by date descending
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Mood.logDate, ascending: false)]
        
        if !searchText.isEmpty {
            // Create predicates to match searchText in moodName, activityName, and categories name, or parse date string
            // Predicate for activityName or moodName contains searchText (case-insensitive)
            let textPredicate = NSPredicate(format: "activityName CONTAINS[cd] %@ OR moodName CONTAINS[cd] %@", searchText, searchText)
            
            // Predicate for categories name contains searchText - linked entity query
            let categoryPredicate = NSPredicate(format: "ANY childCategories.name CONTAINS[cd] %@", searchText)
            
            // Date parsing: try to parse searchText to Date, then match logDate’s day component
            var datePredicate: NSPredicate? = nil
            if let searchDate = dateFormatter.date(from: searchText) {
                // We create a date range to match the whole day (since logDate is a Date)
                let startOfDay = Calendar.current.startOfDay(for: searchDate)
                let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
                datePredicate = NSPredicate(format: "logDate >= %@ AND logDate < %@", startOfDay as NSDate, endOfDay as NSDate)
            }
            
            // Combine predicates with OR
            if let datePredicate = datePredicate {
                request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [textPredicate, categoryPredicate, datePredicate])
            } else {
                request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [textPredicate, categoryPredicate])
            }
        } else {
            request.predicate = nil
        }
        
        do {
            moodItems = try viewContext.fetch(request)
        } catch {
            print("Failed to fetch moods: \(error)")
            moodItems = []
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}

#Preview {
    MoodLogView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
