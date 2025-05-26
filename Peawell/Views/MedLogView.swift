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
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \LogTimeMeds.logTimes, ascending: false)], animation: .default)
    var logEntries: FetchedResults<LogTimeMeds>
    
    //  these define the user input field's empty state
    @State var medName: String = ""
    @State var medAmount: String = ""
    @State var medUnit: String = ""
    
    @State private var editingMed: Meds?
    
    //  define selectable days here
    let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

    var body: some View {
        List {
            Section(header: Text("section.header.medList")) {
                ForEach(medsItems) { item in
                    NavigationLink {
                        List {
                            Section {
                                HStack {
                                    Spacer()
                                    Image(item.medKind ?? "")
                                        .padding()
                                    Spacer()
                                }
                            }
                            .listRowBackground(Color.clear)
                            Section {
                                HStack {
                                    Text("prompt.meds.amount")
                                    Spacer()
                                    Text(item.medDose ?? "")
                                        .font(.title3)
                                        .foregroundColor(Color.secondary)
                                    Text(item.medUnit ?? "")
                                        .font(.title3)
                                        .foregroundColor(Color.secondary)
                                }
                            }
                            if item.medRemind == true && item.schedule?.count ?? 0 > 0 {
                                Section(header: Text("header.schedule")) {
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
                        .toolbar {
                            Button {
                                editingMed = item
                            } label: {
                                Image(systemName: "square.and.pencil")
                            }
                            Button(role: .destructive) {
                                trashItem(objectID: item.objectID)
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                        .navigationTitle(
                            Text(item.medType ?? ""))
                        .sheet(item: $editingMed) { med in
                            ModifyMedsSheetView(med: med)
                        }
                    } label: {
                        HStack() {
                            Image(item.medKind ?? "")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(6)
                                .background(Color.accentColor)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            Text(item.medType ?? "")
                            Spacer()
                            Text(item.medDose ?? "")
                                .opacity(0.4)
                            Text(item.medUnit ?? "")
                                .opacity(0.4)
                        }
                    }
                    .swipeActions(allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            trashItem(objectID: item.objectID)
                        } label: {
                            Image(systemName: "trash")
                        }
                        Button {
                            editingMed = item
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                    }
                }
            }
            Section(header: Text("section.header.medHistory")) {
                ForEach(logEntries, id: \.self) { item in  // Add explicit ID
                    HStack {  // Remove nested List
                        Image(item.medication?.medKind ?? "longPill")  // Access through relationship
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(6)
                            .background(Color.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        Text(item.medication?.medType ?? "Unknown Medication")
                        Spacer()
                        if let logTime = item.logTimes {
                            Text(logTime.formatted(date: .abbreviated, time: .shortened))
                                .opacity(0.4)
                        }
                    }
                    .swipeActions(allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            trashItem(objectID: item.objectID)
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("title.med")
        .sheet(item: $editingMed) { med in
            ModifyMedsSheetView(med: med)
        }
    }
}

#Preview {
    MedLogView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
