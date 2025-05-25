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
    
    @State var isShowingEditDiarySheet = false
    @State var editDiaryEntry = "fixme"
    @State var moodEntry: FetchedResults<Mood>.Element?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(moodItems) { item in
                    NavigationLink {
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
                                Text(item.activityName ?? "Text missing")
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        .toolbar {
                            ToolbarItem {
                                Button() {
                                    self.editDiaryEntry = item.activityName ?? "error"
                                    moodEntry = item
                                    isShowingEditDiarySheet = true
                                } label: {
                                    Label(NSLocalizedString("global.edit.item", comment: "tells screen reader that action edits item"), systemImage: "square.and.pencil")
                                }
                            }
                            ToolbarItem {
                                Button(
                                    role: .destructive
                                ) {
                                    trashItem(objectID: item.objectID)
                                } label: {
                                    Label(NSLocalizedString("global.trash.item", comment: "tells screen reader that action deletes item"), systemImage: "trash")
                                }
                            }
                        }
                        .navigationTitle(Text(item.logDate ?? Date.now, style: .date))
                    } label: {
                        HStack() {
                            Image("mood\(item.moodName ?? "Neutral")")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(6)
                                .background(getMoodColor(item.moodName))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            Text(item.logDate ?? Date.now, style: .date)
                        }
                    }
                    .swipeActions(allowsFullSwipe: true) {
                        Button(
                            role: .destructive
                        ) {
                            trashItem(objectID: item.objectID)
                        } label: {
                            Label(NSLocalizedString("global.trash.item", comment: "tells screen reader that action deletes item"), systemImage: "trash")
                        }
                        Button() {
                            isShowingEditDiarySheet = true
                            self.editDiaryEntry = item.activityName ?? "error"
                        } label: {
                            Label(NSLocalizedString("global.edit.item", comment: "tells screen reader that action edits item"), systemImage: "square.and.pencil")
                            // this is how you set the bg color of the swipe actions and buttons
                                .tint(Color.orange)
                        }
                    }
                    .sheet(isPresented: $isShowingEditDiarySheet) {
                        NavigationView {
                            TextEditor(text: $editDiaryEntry)
                                .padding()
                                .navigationTitle(NSLocalizedString("module.edit.diary", comment: "header telling the user it is an edit screen"))
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbar() {
                                    ToolbarItem {
                                        Button() {
                                            moodEntry?.activityName = editDiaryEntry
                                            saveEdits()
                                            isShowingEditDiarySheet = false
                                        } label: {
                                            Image(systemName: "square.and.arrow.down")
                                        }
                                    }
                                }
                        }
                    }
                }
            }
            .navigationTitle(NSLocalizedString("module.moods", comment: "module name for moods"))
        }
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
