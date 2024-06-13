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
                                /*.background(Color.secondarySystemBackground)
                                 .clipShape(RoundedRectangle(cornerRadius: 10))*/
                                    .padding()
                            }
                        } label: {
                            /*HStack() {
                                Text(item.logDate ?? Date.now, style: .date)
                                Text(" - ")
                                Text(item.moodName ?? "Mood missing")
                            }*/
                            HStack() {

                                Image("mood\(item.moodName ?? "Neutral")")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding(6)
                                    .background(Color.accentColor)
                                /*
                                if item.moodName == "Horrible" {
                                    .background(Color.bgColorHorrible)
                                }
                                if item.moodName == "Bad" {
                                    .background(Color.bgColorBad)
                                }
                                if item.moodName == "Neutral" {
                                    .background(Color.bgColorNeutral)
                                }
                                if item.moodName == "Good" {
                                    .background(Color.bgColorGood)
                                }
                                if item.moodName == "Awesome" {
                                    .background(Color.bgColorAwesome)
                                }
                                */
                                /*
                                switch item.moodName ?? "Neutral" {
                                case "Horrible":
                                        .background(Color.bgColorHorrible)
                                case "Bad":
                                        .background(Color.bgColorBad)
                                case "Neutral":
                                        .background(Color.bgColorNeutral)
                                case "Good":
                                        .background(Color.bgColorGood)
                                case "Awesome":
                                        .background(Color.bgColorAwesome)
                                default:
                                        .background(Color.bgColorNeutral)
                                }
                                */
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
}

struct AddActivityView_Previews: PreviewProvider {
    static var previews: some View {
        OverView()
    }
}
