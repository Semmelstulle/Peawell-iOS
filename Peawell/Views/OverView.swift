//
//  AddActivityView.swift
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

struct OverView: View {
    
    //  adds fetched data to scope
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Meds.medType, ascending: true)], animation: .default)
    var medsItems: FetchedResults<Meds>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Mood.logDate, ascending: false)], animation: .default)
    var moodItems: FetchedResults<Mood>
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text(NSLocalizedString("meds section", comment: "tell the person this is the section containing their logged medication"))) {
                    ForEach(medsItems) { item in
                        HStack() {
                            Text(item.medType ?? "")
                            Text(" - ")
                            Text(item.medDose ?? "")
                            Text(item.medUnit ?? "")
                            Text(item.medKind ?? "")
                        }
                    }
                }
                Section(header: Text(NSLocalizedString("mood section", comment: "tell the person this is the section containing their logged moods"))) {
                    ForEach(moodItems) { item in
                        NavigationLink {
                            ScrollView () {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color.accentColor)
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
                    }
                }
            }
            .navigationTitle("Overview")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
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
}

struct AddActivityView_Previews: PreviewProvider {
    static var previews: some View {
        OverView()
    }
}
