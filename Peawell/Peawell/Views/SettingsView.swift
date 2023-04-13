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
    @AppStorage("settingForceDarkMode") private var settingForceDarkMode = false
    @AppStorage("settingShowMedicationSection") private var settingShowMedicationSection = true
    @AppStorage("settingSynciCloud") private var settingSynciCloud = false
    @AppStorage("settingSyncCalendar") private var settingSyncCalendar = false
    
    @State private var showingDeleteAlert: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Display"),
                        footer: Text("These settings change the look of this app.")
                ) {
                    Toggle(isOn: $settingForceDarkMode, label: {Text("Force dark mode")})
                    Toggle(isOn: $settingShowMedicationSection, label: {Text("Show medication section")})
                }
                Section(header: Text("Access"),
                        footer: Text("Here you need to opt in on using features that the app can't provide on it's own.")
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
                            //print("canceled deletion")
                        }
                        Button("I'm sure", role: .destructive) {
                            UserDefaults.standard.set(false, forKey: "settingForceDarkMode")
                            UserDefaults.standard.set(true, forKey: "settingShowMedicationSection")
                            UserDefaults.standard.set(false, forKey: "settingSynciCloud")
                            UserDefaults.standard.set(false, forKey: "settingSyncCalendar")
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
            }.navigationTitle(settingsTitle)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
