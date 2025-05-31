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
    @AppStorage("selectedAppIcon") private var selectedAppIcon: String = "AppIcon"
    private let appIcons: [(name: String, label: String)] = [
        ("AppIcon", "Default"),
        ("AppIconAlt1", "Flat"),
        ("AppIconAlt2", "Zoom")
    ]
    
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
                    header: Text("App Icon")
                ) {
                    Picker(selection: $selectedAppIcon, label:
                            HStack {
                        Image(uiImage: getAppIconImage(named: selectedAppIcon))
                            .resizable()
                            .frame(width: 42, height: 42)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        Text("App Icon")
                    }
                    ) {
                        ForEach(appIcons, id: \.name) { icon in
                            Text(icon.label)
                                .tag(icon.name)
                        }
                    }
                    .onChange(of: selectedAppIcon) { newValue in
                        UIApplication.shared.setAlternateIconName(newValue == "AppIcon" ? nil : newValue)
                    }
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

// Helper to get app icon image from asset catalog
func getAppIconImage(named name: String) -> UIImage {
    switch name {
    case "AppIcon":
        return UIImage(named: "AppIconPreview") ?? UIImage(systemName: "app") ?? UIImage()
    case "AppIconAlt1":
        return UIImage(named: "AppIconAlt1Preview") ?? UIImage(systemName: "app") ?? UIImage()
    case "AppIconAlt2":
        return UIImage(named: "AppIconAlt2Preview") ?? UIImage(systemName: "app") ?? UIImage()
    default:
        return UIImage(systemName: "app") ?? UIImage()
    }
}
