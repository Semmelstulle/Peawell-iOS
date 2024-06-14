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

    //  adds fetched data to scope
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Mood.logDate, ascending: false)], animation: .default)
    var moodItems: FetchedResults<Mood>

    var body: some View {
        List {
            ForEach(moodItems) { item in
                NavigationLink {
                    ScrollView () {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(getMoodColor(item.moodName))
                                .frame(maxWidth: .infinity, idealHeight: 50)
                                .padding()
                            Image("mood\(item.moodName ?? "Neutral")")
                        }
                        Text(item.activityName ?? "Text missing")
                            .navigationTitle(Text(item.logDate ?? Date.now, style: .date))
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .padding()
                    }
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
                        Label(NSLocalizedString("delete diary", comment: "tell the person this button deletes the diary"), systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle("Mood Log")
    }
}


//prepares the color variables for the diary entries in the list view
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

    //  runs fetch functions to gather all data and delete them
    for object in fetchMood() {
        viewContext.delete(object)
    }
    try? viewContext.save()
}

#Preview {
    MoodLogView()
}
