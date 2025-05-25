//
//  MainView.swift
//  Peawell
//
//  Created by Dennis on 12.04.23.
//

import SwiftUI

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    //  adds UserDefaults to scope
    @AppStorage("settingShowMoodSection") private var settingShowMoodSection = true
    @AppStorage("settingShowMedicationSection") private var settingShowMedicationSection = true
    
    // variables for showing sheets
    @State private var showingSettingsSheet = false
    @State private var isAnimating = false
    
    var body: some View {
        NavigationStack {
            ScrollView() {
                
                CalendarView()
                    .padding()
                
                LogSectionsView()
                    .padding()
                
                //  the next sections are toggled by UserDefaults
                if settingShowMoodSection == true {
                    MoodPickerView()
                        .padding()
                }
                if settingShowMedicationSection == true {
                    MedsView()
                        .padding()
                }
                if settingShowMedicationSection == false && settingShowMoodSection == false {
                    Text(NSLocalizedString("main.empty.hint", comment: "tell the person that all modules are disabled thus there is nothing here."))
                        .padding()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Peawell")
            .toolbar {
                Button {
                    showingSettingsSheet = true
                } label: {
                    Image(systemName: "gear")
                }
            }
            .sheet(isPresented: $showingSettingsSheet) {
                SettingsView()
            }
        }
    }
}

#Preview {
    MainView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
