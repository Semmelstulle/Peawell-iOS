//
//  SettingsView.swift
//  Peawell
//
//  Created by Dennis on 12.04.23.
//

import SwiftUI

//  constants declared on top
let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

struct SettingsView: View {
    var body: some View {
        NavigationView {
            Form {
                
                Section(header: Text("Display"),
                        footer: Text("These settings change the look of this app.")
                ) {
                    Toggle(isOn: .constant(false), label: {Text("Force dark mode")})
                    Toggle(isOn: .constant(true), label: {Text("Show medication section")})
                }
                Section(header: Text("Access"),
                        footer: Text("Here you need to opt in on using features that the app can't provide on it's own.")
                ) {
                    Toggle(isOn: .constant(false), label: {Text("Sync to iCloud")})
                    Toggle(isOn: .constant(false), label: {Text("Add to local calendar")})
                }
                Section(header: Text("Delete files"),
                        footer: Text("This can not be undone!")
                ) {
                    Label("Reset all data", systemImage: "trash").foregroundColor(.red)
                }
                Section(header: Text("About this project")
                ) {
                    Link(destination: URL(string: "https://mastodon.social/@semmelstulle")!,
                         label: { Label("Developer on Mastodon", systemImage: "link").foregroundColor(.blue)
                    })
                    Link(destination: URL(string: "https://mastodon.social/@semmelstulle")!,
                         label: { Label("App on GitHub", systemImage: "link").foregroundColor(.blue)
                    })
                    Text("App version: " + (appVersion ?? String("failed to get")))
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
