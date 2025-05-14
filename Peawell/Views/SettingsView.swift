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
    
    //  needs to make delete alert invisible until it is needed
    @State private var showingDeleteAlert: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(NSLocalizedString("settings.modules.header", comment: "tells the user this section is for managing modules of the app")), footer: Text(NSLocalizedString("settings.modules.footer", comment: "short description to tell user what the toggles do"))
                ) {
                    Toggle(isOn: $settingShowMoodSection, label: {Text(NSLocalizedString("settings.toggle.module.mood", comment: "short hint that mood module is toggled"))})
                    Toggle(isOn: $settingShowMedicationSection, label: {Text(NSLocalizedString("settings.toggle.module.med", comment: "short hint that med module is toggled"))})
                }
                Section(header: Text(NSLocalizedString("settings.access.header", comment: "just says access in things the app can access")), footer: Text(NSLocalizedString("settings.access.footer", comment: "tells that the user can control here what the app gets access to"))
                ) {
                    Toggle(isOn: $settingSynciCloud, label: {Text(NSLocalizedString("settings.toggle.CloudKit", comment: "tells the user that data will be stored to iCloud when on"))})
                }
                Section(header: Text(NSLocalizedString("settings.toggle.reset.header", comment: "hints that below data will be erased")),
                        footer: Text(NSLocalizedString("settings.toggle.reset.footer", comment: "makes clear to user that erasing is irreversible"))
                ) {
                    Button(action: {
                        self.showingDeleteAlert = true
                        hapticWarning()
                    }, label: {
                        Label(NSLocalizedString("settings.button.reset", comment: "just should say delete"), systemImage: "trash").foregroundColor(.red)
                    })
                    
                    //  confirmation alert is designed here
                    .alert(NSLocalizedString("settings.button.reset.alert", comment: "dialog that again tells deletion can not be undone"), isPresented: $showingDeleteAlert) {
                        Button(NSLocalizedString("settings.button.reset.alert.cancel", comment: "just should say cancel"), role: .cancel) {
                            //  nothing here, action is cancelled
                        }
                        Button(NSLocalizedString("settings.button.reset.alert.confirm", comment: "reassures the user really want to clear data"), role: .destructive) {
                            resetData()
                        }
                    }
                }
                //  links to project and dev
                Section(header: Text(NSLocalizedString("settings.section.about", comment: "says 'about this project'"))
                ) {
                    Link(destination: URL(string: "https://mastodon.social/@semmelstulle")!,
                         label: { Label(NSLocalizedString("settings.socials.mastodon", comment: "says that this is the dev's Mastodon page"), systemImage: "link").foregroundColor(.blue)
                    })
                    Link(destination: URL(string: "https://github.com/SemmelStulle/Peawell_iOS")!,
                         label: { Label(NSLocalizedString("settings.socials.github", comment: "says that this is the app's GitHub page"), systemImage: "link").foregroundColor(.blue)
                    })
                    //  HStack so not all of it is crammed on the left side
                    HStack() {
                        Text(NSLocalizedString("settings.version.info", comment: "says 'app version'")).foregroundColor(.secondary)
                        Spacer()
                        Text(appVersion ?? String(NSLocalizedString("settings.version.release", comment: "says version missing"))).foregroundColor(.secondary)
                    }
                }
                HStack() {
                    //  oh, hello there!
                    Spacer()
                    Text(NSLocalizedString("settings.footer", comment: "greets international users from germany with a german flag ")).foregroundColor(.secondary)
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle(NSLocalizedString("module.settings", comment: "should just say settings to tell the user where it navigates to"))
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
