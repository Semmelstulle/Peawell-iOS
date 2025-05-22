//
//  MedLogView.swift
//  Peawell
//
//  Created by dennis on 14.06.24.
//

import SwiftUI

struct MedLogView: View {

    //  adds fetched data to scope
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Meds.medType, ascending: true)], animation: .default)
    var medsItems: FetchedResults<Meds>
    
    //  these define the user input field's empty state
    @State var medName: String = ""
    @State var medAmount: String = ""
    @State var medUnit: String = ""
    
    //  define selectable days here
    let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

    var body: some View {
        List {
            Section {
                ForEach(medsItems) { item in
                    // sub pages where the user can read more about dose, schedule etc.
                    NavigationLink {
                        List {
                            Section {
                                HStack {
                                    Spacer()
                                    Image(item.medKind ?? "")
                                        //  disabled for now to have
                                        //  a look on the effect
                                        //.resizable()
                                        //.frame(width: 120, height: 120)
                                        .padding()
                                    Spacer()
                                }
                            }
                            //  needed so the icon has no list styling
                            //  below it
                            .listRowBackground(Color.clear)
                            Section {
                                //  tells medication dose to user
                                HStack {
                                    Text(NSLocalizedString("add.meds.medDose", comment: "ask for medication dose"))
                                    Spacer()
                                    Text(item.medDose ?? "")
                                        .font(.title3)
                                        .foregroundColor(Color.secondary)
                                    Text(item.medUnit ?? "")
                                        .font(.title3)
                                        .foregroundColor(Color.secondary)
                                }
                            }
                            //  list schedule for user
                            if item.medRemind == true && item.schedule?.count ?? 0 > 0 {
                                Section(header: Text("Schedule")) {
                                    if let schedules = item.schedule as? Set<Schedules>, let schedule = schedules.first {
                                        if let days = schedule.dates as? Set<Int> {
                                            ForEach(Array(days).sorted(), id: \.self) { day in
                                                Text(weekdays[day])
                                            }
                                        }
                                        
                                        if let times = schedule.times as? Set<Date> {
                                            ForEach(Array(times).sorted(by: { $0 < $1 }), id: \.self) { time in
                                                Text(time.formatted(date: .omitted, time: .shortened))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .navigationTitle(
                            Text(item.medType ?? ""))
                    } label: {
                        //  the list view of medications that can be
                        //  logged by the user
                        HStack() {
                            Image(item.medKind ?? "")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(6)
                                .background(Color("\(item.medKind ?? "roundPill")Color"))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            Text(item.medType ?? "")
                            Spacer()
                            Text(item.medDose ?? "")
                                .opacity(0.4)
                            Text(item.medUnit ?? "")
                                .opacity(0.4)
                        }
                    }
                    // delete action when swiping on the item
                    .swipeActions(allowsFullSwipe: true) {
                        Button(
                            role: .destructive
                        ) {
                            trashItem(objectID: item.objectID)
                        } label: {
                            Label(NSLocalizedString("global.trash.item", comment: "tells screen reader that action deletes item"), systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle(NSLocalizedString("module.med", comment: "module name for meds"))
    }
}

#Preview {
    MedLogView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
