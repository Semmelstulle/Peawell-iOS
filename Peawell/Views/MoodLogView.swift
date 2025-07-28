//
//  MoodLogView.swift
//  Peawell
//
//  Created by Dennis on 12.04.23.
//

import SwiftUI

//  prepares colors
var bgColorHorrible: Color = Color.red
var bgColorBad: Color = Color.orange
var bgColorNeutral: Color = Color.yellow
var bgColorGood: Color = Color.green
var bgColorAwesome: Color = Color.mint

struct MoodLogView: View {
    
    // adds fetched data to scope
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Mood.logDate, ascending: false)], animation: .default)
    var moodItems: FetchedResults<Mood>
    
    @State var editingEntry: Mood? = nil
    @State var isShowingEditDiarySheet = false
    
    @State private var showingDeleteAlert = false
    @State var editDiaryEntry = "fixme"
    @State var moodEntry: FetchedResults<Mood>.Element?
    
    var body: some View {
        List {
            ForEach(moodItems) { item in
                NavigationLink {
                    detailedJournal(for: item)
                } label: {
                    allJournals(for: item)
                }
                .swipeActions(allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        trashItem(objectID: item.objectID)
                    } label: {
                        Image(systemName: "trash")
                    }
                    Button {
                        self.editDiaryEntry = item.activityName ?? "error.hint"
                        moodEntry = item
                        isShowingEditDiarySheet = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
                .sheet(isPresented: $isShowingEditDiarySheet) {
                    
                }
            }
        }
        .navigationTitle("title.diary")
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
        List () {
            Section {
                HStack {
                    Spacer()
                    Image("mood\(item.moodName ?? "Neutral")")
                    Spacer()
                }
            }
            .listRowBackground(getMoodColor(item.moodName))
            Section {
                FlowLayout {
                    ForEach(Array(item.childCategories as? Set<MoodCategories> ?? [])) { category in
                        ChipView(
                            category: MoodCategory(
                                name: category.name ?? "",
                                sfsymbol: category.sfsymbol,
                                isBuiltIn: true // or retrieve actual value if stored
                            ),
                            isSelected: true,
                            onTap: {}
                        )
                    }
                }
            }
            .listRowBackground(Color.clear)
            Section {
                Text(item.activityName ?? "Text missing")
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .toolbar {
            Button {
                self.editDiaryEntry = item.activityName ?? "error"
                moodEntry = item
                isShowingEditDiarySheet = true
            } label: {
                Image(systemName: "square.and.pencil")
            }
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
}

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

#Preview {
    MoodLogView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    
}
