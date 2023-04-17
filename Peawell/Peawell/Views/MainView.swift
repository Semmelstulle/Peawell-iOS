//
//  MainView.swift
//  Peawell
//
//  Created by Dennis on 12.04.23.
//

import SwiftUI

struct MainView: View {

    //  adds fetched data to scope
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Mood.moodName, ascending: true)], animation: .default)
    var moodItems: FetchedResults<Mood>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Meds.medType, ascending: true)], animation: .default)
    var medsItems: FetchedResults<Meds>

    //  adds UserDefaults to scope
    @AppStorage("settingShowMoodSection") private var settingShowMoodSection = true
    @AppStorage("settingShowMedicationSection") private var settingShowMedicationSection = true

    var body: some View {
        NavigationView {
            ScrollView() {
                // checks UserDefaults if section is active
                if settingShowMoodSection == true {
                    VStack() {
                        HStack(spacing: 10) {
                            ForEach(0..<7) { index in
                                DayButtonView(label: "\(index+1)")
                            }
                        }
                        HStack(spacing: 10) {
                            ForEach(0..<7) { index in
                                DayButtonView(label: "\(index+8)")
                            }
                        }
                    }.padding()
                }
                //  checks UserDefaults if section is active
                if settingShowMedicationSection == true {
                    LazyVGrid(columns: [.init(), .init()]) {
                        PanelView(
                            icon:
                                Image(systemName: "plus")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.accentColor)
                                .aspectRatio(1, contentMode: .fill)
                                .clipShape(Circle()),
                            doseAmnt: String(medsItems.count),
                            doseUnit: "",
                            title: "Medications"
                        )
                        ForEach(medsItems) { item in
                            PanelView(
                                icon:
                                    Image(systemName: "pills")
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.gray)
                                    .aspectRatio(1, contentMode: .fill)
                                    .clipShape(Circle()),
                                doseAmnt: String(item.medDose ?? ""),
                                doseUnit: "mg",
                                title: String(item.medType ?? "")
                            )
                            .contextMenu() {
                                Button() {
                                    // either call a sheet or a new view here to edit entry
                                } label: {
                                    Label("Edit medication", systemImage: "pencil")
                                }
                                Button(role: .destructive) {
                                    trashMeds(objectID: item.objectID)
                                } label: {
                                    Label("Delete medication", systemImage: "trash")
                                }
                            }
                        }
                    }.padding()
                }
                Section(header: Text("Mood log")) {
                    ForEach(moodItems) { item in
                        HStack() {
                            Text(item.activityName ?? "Error")
                            Text(item.moodName ?? "Error")
                        }
                    }
                }
            }
            .navigationTitle(mainTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
    
    //  prepares the day cell
    struct DayButtonView: View {
        @State var label: String
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous).foregroundColor(.accentColor).aspectRatio(1, contentMode: .fit);
                Text(label)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
