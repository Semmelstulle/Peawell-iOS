//
//  SettingsView.swift
//  Peawell
//
//  Created by Dennis on 12.04.23.
//

import SwiftUI
import CoreHaptics

//  constants declared on top
//  this only checks the app version from within itself
let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

struct SettingsView: View {
    
    //  settings stored in UserDefaults wrapped with AppStorage
    @AppStorage("settingShowMoodSection") var settingShowMoodSection = true
    @AppStorage("settingShowMedicationSection") var settingShowMedicationSection = true
    @AppStorage("settingSynciCloud") var settingSynciCloud = false
    @AppStorage("settingSyncCalendar") var settingSyncCalendar = false
    
    @State private var showingDeleteAlert: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Modules"), footer: Text("These settings toggle the modules of this app.")
                ) {
                    Toggle(isOn: $settingShowMoodSection, label: {Text("Use mood module")})
                    Toggle(isOn: $settingShowMedicationSection, label: {Text("Use medication module")})
                }
                Section(header: Text("Access"), footer: Text("Here you need to opt in on using features that the app can't provide on it's own.")
                ) {
                    Toggle(isOn: $settingSynciCloud, label: {Text("Sync to iCloud")})
                    Toggle(isOn: $settingSyncCalendar, label: {Text("Add to local calendar")})
                }
                Section(header: Text("Delete files"),
                        footer: Text("This can not be undone!")
                ) {
                    Button(action: {
                        self.showingDeleteAlert = true
                        hapticWarning()
                    }, label: {
                        Label("Reset data", systemImage: "trash").foregroundColor(.red)
                    })
                    //.onTapGesture(perform: hapticWarning)
                    
                    //  confirmation alert is designed here
                    .alert("This can not be reverted!\nDo you really want to reset the app?", isPresented: $showingDeleteAlert) {
                        Button("Cancel", role: .cancel) {
                            //  nothing here, action is cancelled
                        }
                        Button("I'm sure", role: .destructive) {
                            resetData()
                        }
                    }
                }
                Section(header: Text("About this project")
                ) {
                    Link(destination: URL(string: "https://mastodon.social/@semmelstulle")!,
                         label: { Label("Developer on Mastodon", systemImage: "link").foregroundColor(.blue)
                    })
                    Link(destination: URL(string: "https://github.com/SemmelStulle/Peawell_iOS")!,
                         label: { Label("App on GitHub", systemImage: "link").foregroundColor(.blue)
                    })
                    //  HStack so not all of it is crammed on the left side
                    HStack() {
                        Text("App version").foregroundColor(.secondary)
                        Spacer()
                        Text(appVersion ?? String("failed to get")).foregroundColor(.secondary)
                    }
                }
                HStack() {
                    Spacer()
                    Text("Made with love in 🇩🇪").foregroundColor(.secondary)
                    Spacer()
                }.listRowBackground(Color.clear)
            }.navigationTitle(settingsTitle)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
