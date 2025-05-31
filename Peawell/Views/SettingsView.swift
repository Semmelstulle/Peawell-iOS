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
    @Environment(\.dismiss) private var dismiss
    
    //  settings stored in UserDefaults wrapped with AppStorage
    @AppStorage("settingShowMoodSection") var settingShowMoodSection = true
    @AppStorage("settingShowMedicationSection") var settingShowMedicationSection = true
    
    //  needs to make delete alert invisible until it is needed
    @State private var showingDeleteAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(
                    header: Text("section.header.modules"),
                    footer: Text("section.footer.modules")
                ) {
                    Toggle(
                        isOn: $settingShowMoodSection,
                        label: {Text("toggle.show.mood")})
                    
                    Toggle(
                        isOn: $settingShowMedicationSection,
                        label: {Text("toggle.show.med")}
                    )
                }
                Section(
                    header: Text("section.header.reset"),
                    footer: Text("section.footer.reset")
                ) {
                    Button(action: {
                        self.showingDeleteAlert = true
                        hapticWarning()
                    }, label: {
                        Label(
                            "button.reset",
                            systemImage: "trash"
                        )
                        .foregroundColor(.red)
                    })
                    
                    //  confirmation alert is designed here
                    .alert("dialog.infoText", isPresented: $showingDeleteAlert) {
                        Button("button.dialog.cancelReset", role: .cancel) {
                            //  nothing here, action is cancelled
                        }
                        Button("button.dialog.confirmReset", role: .destructive) {
                            resetData()
                        }
                    }
                }
                //  links to project and dev
                Section(
                    header: Text("section.header.about")
                ) {
                    Link(
                        destination: URL(string: "https://mastodon.social/@semmelstulle")!,
                        label: {
                            Label("link.socials.mastodon", systemImage: "link").foregroundColor(.blue)
                        }
                    )
                    Link(
                        destination: URL(string: "https://github.com/SemmelStulle/Peawell_iOS")!,
                        label: {
                            Label("link.socials.github", systemImage: "link").foregroundColor(.blue)
                        }
                    )
                    //  HStack so not all of it is crammed on the left side
                    HStack() {
                        Text("suffix.appVersion")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(appVersion ?? String("N/A"))
                            .foregroundColor(.secondary)
                    }
                }
                HStack() {
                    //  oh, hello there!
                    Spacer()
                    Text("greeter.settings")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle("title.settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                            .font(.system(size: 25))
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
