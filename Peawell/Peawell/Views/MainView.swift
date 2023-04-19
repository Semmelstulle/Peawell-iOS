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

    @State private var showMedsSheet: Bool = false
    @State var medSheetTitle: String = ""
    @State var medSheetDose: String = ""
    //@State var medSheetUnit: String = ""
    //@State var medSheetReminders: String = ""

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
                            showMedsSheet = true
                            medSheetTitle = "Add Medication"
                            medSheetDose = ""
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
                                    showMedsSheet = true
                                    medSheetTitle = String(item.medType ?? "")
                                    medSheetDose = String(item.medDose ?? "")
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
            }
            .navigationTitle(mainTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .sheet(isPresented: $showMedsSheet) {
                if #available (iOS 16.0, *) {
                    MedsSheetView(medsSheetTitle: medSheetTitle
                                  //, medsSheetDose: medSheetDose
                    )
                    .presentationDetents(
                        [.medium, .large])
                } else {
                    MedsSheetView(medsSheetTitle: medSheetTitle
                                  //, medsSheetDose: medSheetDose
                    )
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
