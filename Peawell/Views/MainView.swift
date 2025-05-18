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
    @State private var showingJournalSheet = false
    
    //  gets current date and formats it so it can be used as the
    //  navigationTitle for the view
    var navTitleDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d. MMM."
        return formatter.string(from: Date())
    }

    var body: some View {
        NavigationView {
            ScrollView() {
                
                CalendarProgressView()
                    .frame(height: 80)
                    .padding()

                LogSectionsView()
                
                //  the next sections are toggled by UserDefaults
                if settingShowMoodSection == true {
                    MoodPickerView()
                        .padding(.horizontal)
                        .padding(.top, 0)
                        .padding(.bottom)
                }
                if settingShowMedicationSection == true {
                    MedsView()
                        .padding(.horizontal)
                        .padding(.top, 0)
                        .padding(.bottom)
                }
                if settingShowMedicationSection == false && settingShowMoodSection == false {
                    Text(NSLocalizedString("main.empty.hint", comment: "tell the person that all modules are disabled thus there is nothing here."))
                        .padding()
                }
            }
            .navigationTitle(navTitleDate)
            //  is needed so the text is not centered in view
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .toolbar {
                ToolbarItemGroup() {
                    Button {
                        showingSettingsSheet = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingSettingsSheet) {
                if #available(iOS 16, *) {
                    SettingsView()
                        .presentationDetents([.medium, .large])
                } else {
                    SettingsView()
                }
            }
        }
    }
}

#Preview {
    MainView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
