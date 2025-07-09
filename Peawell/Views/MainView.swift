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
    @State private var showingMoodPickerSheet = false
    @State private var selectedMoodName: String? = nil
    
    // Mood options for the picker
    let moodOptions: [(color: Color, name: String, image: String)] = [
        (.red, "Horrible", "moodHorrible"),
        (.orange, "Bad", "moodBad"),
        (.yellow, "Neutral", "moodNeutral"),
        (.green, "Good", "moodGood"),
        (.mint, "Awesome", "moodAwesome")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView() {
                CalendarView()
                    .padding()
                LogSectionsView()
                    .padding()
                //  the next sections are toggled by UserDefaults
                if settingShowMoodSection == true {
                    Section(header: sectionHeader) {
                        HStack {
                            ForEach(moodOptions, id: \.name) { option in
                                MoodButtonView(
                                    panelColor: option.color,
                                    moodImage: option.image,
                                    moodName: option.name,
                                    isSelected: selectedMoodName == option.name,
                                    anySelected: selectedMoodName != nil,
                                    onTap: {
                                        selectedMoodName = option.name
                                        showingMoodPickerSheet = true
                                    }
                                )
                                .animation(.easeInOut, value: selectedMoodName)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadiusPrimary))
                        .padding(.top, -12)
                    }
                    .listStyle(.plain)
                    .padding([.leading, .trailing, .bottom])
                }
                if settingShowMedicationSection == true {
                    MedsView()
                        .padding(.horizontal)
                }
                if settingShowMedicationSection == false && settingShowMoodSection == false {
                    Text("main.empty.hint")
                        .padding()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("title.mainScreen")
            .toolbar {
                ToolbarItem {
                    Button {
                        showingSettingsSheet = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                if #available(iOS 26, *) {
                    ToolbarSpacer(.fixed)
                }
            }
            .sheet(isPresented: $showingSettingsSheet) {
                SettingsView()
            }
            .sheet(isPresented: $showingMoodPickerSheet) {
                if let moodName = selectedMoodName {
                    MoodPickerView(moodName: moodName) {
                        // On dismiss, clear selected mood
                        selectedMoodName = nil
                    }
                    .onDisappear {
                        selectedMoodName = nil
                    }
                }
            }
        }
    }
}

private var sectionHeader: some View {
    HStack {
        Text("title.diary")
            .font(.title2.bold())
        Spacer()
    }
    .padding(.horizontal, 4)
}

#Preview {
    MainView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
