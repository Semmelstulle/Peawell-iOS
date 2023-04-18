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

    @State private var showSettingsSheet: Bool = false

    var body: some View {
        NavigationView {
            ScrollView() {
                CalendarView()
                    .padding()
                // checks UserDefaults if section is active
                if settingShowMoodSection == true {
                    MoodPickerView()
                        .padding()
                }
                //  checks UserDefaults if section is active
                if settingShowMedicationSection == true {
                    LazyVGrid(columns: [.init(), .init()]) {
                        PanelView(
                            icon:
                                Image("plus")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.accentColor)
                                .aspectRatio(1, contentMode: .fill)
                                .clipShape(Circle()),
                            doseAmnt: String(medsItems.count),
                            doseUnit: "",
                            title: "Medications"
                        )
                        .onTapGesture {
                            // sheet here
                        }
                        ForEach(medsItems) { item in
                            PanelView(
                                icon:
                                    Image("pillLong")
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
                                    // bla
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
                    }
                    .padding()
                }
                // checks UserDefaults if section is active
                if settingShowMoodSection == true {
                    Section(header: Text("Mood log")) {
                        ForEach(moodItems) { item in
                            HStack() {
                                Text(item.activityName ?? "Error")
                                Text(item.moodName ?? "Error")
                            }
                        }
                    }
                }

            }
            .navigationTitle(mainTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .toolbar() {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "gear")
                        .onTapGesture() {
                            showSettingsSheet = true
                        }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddActivityView()) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showSettingsSheet) {
                if #available (iOS 16.0, *) {
                    SettingsView().presentationDetents(
                        [.medium, .large])
                } else {
                    SettingsView()
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
