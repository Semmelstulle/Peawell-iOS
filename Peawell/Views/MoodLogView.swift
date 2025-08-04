//
//  MoodLogView.swift
//  Peawell
//
//  Created by Dennis on 12.04.23.
//

import SwiftUI
import CoreData

struct MoodLogView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // Fetch moods sorted descending by logDate (live updating)
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Mood.logDate, ascending: false)],
        animation: .default
    )
    private var moods: FetchedResults<Mood>

    @State private var searchText: String = ""

    // Editing state and sheet presentation
    @State private var editingMood: Mood?

    var body: some View {
        List {
            ForEach(filteredMoods, id: \.objectID) { item in
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
                    moodToEdit.activityName = newActName
                    moodToEdit.moodName = newMoodName
                    moodToEdit.logDate = newLogDate

                    if let existingCategories = moodToEdit.childCategories as? Set<MoodCategories> {
                        for category in existingCategories {
                            moodToEdit.removeFromChildCategories(category)
                        }
                    }
                    let context = viewContext
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
                    do {
                        try context.save()
                    } catch {
                        print("Failed to save edited Mood: \(error)")
                    }
                    editingMood = nil
                },
                onDismiss: {
                    editingMood = nil
                }
            )
        }
    }

    private var filteredMoods: [Mood] {
        if searchText.isEmpty {
            return Array(moods)
        }
        let lowercasedSearch = searchText.lowercased()

        return moods.filter { mood in
            let activityMatch = mood.activityName?.lowercased().contains(lowercasedSearch) ?? false
            let moodNameMatch = mood.moodName?.lowercased().contains(lowercasedSearch) ?? false
            let categoryMatch = (mood.childCategories as? Set<MoodCategories>)?.contains(where: {
                $0.name?.lowercased().contains(lowercasedSearch) ?? false
            }) ?? false
            return activityMatch || moodNameMatch || categoryMatch
        }
    }

    @ViewBuilder
    func allJournals(for item: Mood) -> some View {
        HStack(spacing: 16) {
            Image("mood\(item.moodName ?? "Neutral")")
                .resizable()
                .frame(width: 20, height: 20)
                .padding(6)
                .background(getMoodColor(item.moodName))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading) {
                Text(item.logDate ?? Date.now, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(item.activityName ?? "")
                    .font(.body)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
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

            if let categories = item.childCategories as? Set<MoodCategories>, !categories.isEmpty {
                Section {
                    FlowLayout {
                        ForEach(Array(categories)) { category in
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
                }
                .padding(.horizontal, -20)
                .padding(.vertical, -16)
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
            // Note: no confirmation dialog here; delete is handled via swipe action
        }
        .navigationTitle(Text(item.logDate ?? Date.now, style: .date))
    }

    private func editButton(for item: Mood) -> some View {
        Button {
            editingMood = item
        } label: {
            Image(systemName: "square.and.pencil")
        }
    }

    private func deleteButton(for item: Mood) -> some View {
        Button(role: .destructive) {
            // Uses your global trashItem function, assumed to accept NSManagedObjectID
            trashItem(objectID: item.objectID)
        } label: {
            Image(systemName: "trash")
        }
        .tint(.red)
    }
}


#Preview {
    MoodLogView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
