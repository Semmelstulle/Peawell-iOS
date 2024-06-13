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
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Mood.logDate, ascending: true)], animation: .default)
    var moodItems: FetchedResults<Mood>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Meds.medType, ascending: true)], animation: .default)
    var medsItems: FetchedResults<Meds>
    
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
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color.accentColor)
                                    .frame(maxWidth: .infinity, maxHeight: 50)
                                    .padding()
                                Image("mood\(item.moodName ?? "Neutral")")
                            }
                            //Text(item.moodName ?? "Mood missing")
                            Text(item.activityName ?? "Text missing")
                                .navigationTitle(Text(item.logDate ?? Date.now, style: .date))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } label: {
                            HStack() {
                                Text(item.logDate ?? Date.now, style: .date)
                                Text(" - ")
                                Text(item.moodName ?? "Mood missing")
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
}

struct AddActivityView_Previews: PreviewProvider {
    static var previews: some View {
        OverView()
    }
}
