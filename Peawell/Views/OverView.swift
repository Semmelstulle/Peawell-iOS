//
//  AddActivityView.swift
//  Peawell
//
//  Created by Dennis on 12.04.23.
//

import SwiftUI

struct OverView: View {
    
    //  adds fetched data to scope
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Mood.logDate, ascending: true)], animation: .default)
    var moodItems: FetchedResults<Mood>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Meds.medType, ascending: true)], animation: .default)
    var medsItems: FetchedResults<Meds>
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text(NSLocalizedString("mood section", comment: "tell the person this is the section containing their logged moods"))) {
                    ForEach(moodItems) { item in
						NavigationLink {
							HStack() {
								Text(item.moodName ?? "")
								Text(" - ")
								Text(item.activityName ?? "")
							}
						} label: {
							HStack() {
								Text(item.moodName ?? "")
								Text(" - ")
								Text(item.activityName ?? "")
							}
						}
						/*HStack() {
                            Text(item.moodName ?? "")
                            Text(" - ")
                            Text(item.activityName ?? "")
                        }*/
                    }
                }
				.onDelete(perform: deleteItems)
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
				.onDelete(perform: deleteItems)
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
