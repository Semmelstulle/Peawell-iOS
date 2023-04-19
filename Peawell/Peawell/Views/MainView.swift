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

    //  adds UserDefaults to scope
    @AppStorage("settingShowMoodSection") private var settingShowMoodSection = true
    @AppStorage("settingShowMedicationSection") private var settingShowMedicationSection = true

    @State private var showMedsSheet: Bool = false

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
                    MedsView()
                        .padding()
                }
            }
            .navigationTitle(mainTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
