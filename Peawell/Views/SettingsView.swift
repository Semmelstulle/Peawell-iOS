//
//  SettingsView.swift
//  Peawell
//
//  Created by Dennis on 12.04.23.
//

import SwiftUI
import CoreHaptics
import UserNotifications
import UniformTypeIdentifiers

//  constants declared on top
//  this only checks the app version from within itself
let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    //  settings stored in UserDefaults wrapped with AppStorage
    @AppStorage("settingShowMoodSection") var settingShowMoodSection = true
    @AppStorage("settingShowMedicationSection") var settingShowMedicationSection = true
    @AppStorage("selectedAppIcon") private var selectedAppIcon: String = "AppIcon"
    @AppStorage("selectedAccentColor") private var selectedAccentColor: String = "AccentColor"

    private let appIcons: [(name: String, label: String)] = [
        ("AppIcon", "Default"),
        ("AppIconAlt1", "Flat"),
        ("AppIconAlt2", "Zoom")
    ]
    
    private let accentColors: [(name: String, label: String)] = [
        ("AccentColor", "Green"),
        ("AccentColor 1", "Orange"),
        ("AccentColor 2", "Rose"),
        ("AccentColor 3", "Teal"),
        ("AccentColor 4", "Purple")
    ]
        
    //  needs to make delete alert invisible until it is needed
    @State private var showingDeleteAlert: Bool = false
    
    //  developer menu state
    @State private var tapCount = 0
    @State private var showDebugMenu = false
    
    //  export function state
    @State private var showingExporter = false
    @State private var exportURL: URL?
    @State private var showingImporter = false
    @State private var importResult: Result<URL, Error>?
    @State private var showImportSuccess = false
    @State private var showImportFailed = false
    
    //  debug settings state
    @State private var amount: Double = 100
    
    // notification settings
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("journalingRemindersEnabled") private var journalingRemindersEnabled = false
    @AppStorage("journalingReminderDay") private var journalingReminderDay = 1
    @AppStorage("journalingReminderHour") private var journalingReminderHour = 09
    @AppStorage("journalingReminderMinute") private var journalingReminderMinute = 0
    
    private let daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    @State private var showingNotificationPermissionAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section(
                    header: Text("section.header.notifications")
                ) {
                    Toggle(
                        isOn: $notificationsEnabled,
                        label: {Text("toggle.allow.notifications")}
                    )
                    .onChange(of: notificationsEnabled) { newValue in
                        if newValue {
                            requestNotificationPermission()
                        }
                    }
                    NavigationLink("title.journal.schedule", destination: JournalScheduleView())
                        .disabled(!notificationsEnabled)
                }
                
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
                    header: Text("header.iconPicker")
                ) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(appIcons, id: \.name) { icon in
                                Button(action: {
                                    selectedAppIcon = icon.name
                                    UIApplication.shared.setAlternateIconName(icon.name == "AppIcon" ? nil : icon.name)
                                }) {
                                    Image(uiImage: getAppIconImage(named: icon.name))
                                        .resizable()
                                        .frame(width: 54, height: 54)
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(selectedAppIcon == icon.name ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: selectedAppIcon == icon.name ? 2 : 1)
                                        )
                                        .padding(.horizontal, 2)
                                        .padding(.vertical, -6)
                                        .animation(.spring(), value: selectedAppIcon)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section(
                    header: Text("section.header.accentColor")
                ) {
                    Picker("picker.chooseAccentColor", selection: $selectedAccentColor) {
                        ForEach(accentColors, id: \.name) { color in
                            HStack {
                                Text(color.label)
                                Spacer()
                                Color(uiColor: UIColor(named: color.name) ?? .systemBlue)
                                    .frame(width: 24, height: 24)
                                    .clipShape(Circle())
                            }
                            .tag(color.name)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section(
                    header: Text("section.header.data"),
                    footer: Text("section.footer.data")
                ) {
                    Button(action: {
                        if let url = exportUserData() {
                            self.exportURL = url
                            self.showingExporter = true
                        }
                    }, label: {
                        Label("button.exportData", systemImage: "square.and.arrow.up")
                    })
                    
                    Button(action: {
                        self.showingImporter = true
                    }, label: {
                        Label("button.importData", systemImage: "square.and.arrow.down")
                    })
                }
                .fileExporter(
                    isPresented: $showingExporter,
                    document: exportURL.map { URLDocument(url: $0) },
                    contentType: .json,
                    defaultFilename: "Peawell_Export"
                ) { result in
                    // Handle provider result if needed
                }
                .fileImporter(
                    isPresented: $showingImporter,
                    allowedContentTypes: [.json]
                ) { result in
                    switch result {
                    case .success(let url):
                        let accessed = url.startAccessingSecurityScopedResource()
                        defer {
                            if accessed { url.stopAccessingSecurityScopedResource() }
                        }
                        if importUserData(from: url) {
                            showImportSuccess = true
                        } else {
                            showImportFailed = true
                        }
                    case .failure(_):
                        showImportFailed = true
                    }
                }
                .alert("alert.importSuccessful", isPresented: $showImportSuccess) { Button("alert.dismiss", role: .cancel) { } }
                .alert("alert.importFailed", isPresented: $showImportFailed) { Button("alert.dismiss", role: .cancel) { } }
                
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
                    Link(
                        destination: URL(string: "https://peawell.app/privacy/")!,
                        label: {
                            Label("link.legal.privacyPolicy", systemImage: "link").foregroundColor(.blue)
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
                    .onTapGesture {
                        tapCount += 1
                        if tapCount >= 5 {
                            showDebugMenu = true
                            hapticConfirm()
                        }
                    }
                }
                
                //  Developer menu section
                if showDebugMenu {
                    Section(
                        header: Text("section.header.debug")
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
                        .confirmationDialog("dialog.infoText", isPresented: $showingDeleteAlert) {
                            Button("button.dialog.cancelReset", role: .cancel) {
                                showingDeleteAlert = false
                            }
                            Button("button.dialog.confirmReset", role: .destructive) {
                                resetData()
                            }
                        }
                        Button(action: {
                            self.showingDeleteAlert = true
                            hapticWarning()
                        }, label: {
                            Label(
                                "button.resetUserdata",
                                systemImage: "trash"
                            )
                            .foregroundColor(.red)
                        })
                        .confirmationDialog("dialog.infoText", isPresented: $showingDeleteAlert) {
                            Button("button.dialog.cancelReset", role: .cancel) {
                                showingDeleteAlert = false
                            }
                            Button("button.dialog.confirmReset", role: .destructive) {
                                resetUserData()
                            }
                        }
                        Button("Create \(Int(amount)) dummy entries") {
                            do {
                                try createDummyData(context: PersistenceController.shared.container.viewContext, amount: Int(amount))
                                print("Dummy data created")
                            } catch {
                                print("Failed to create dummy data: \(error)")
                            }
                            hapticConfirm()
                        }
                        Slider(value: $amount, in: 1...1_000) {
                            Text("\(Int(amount))")
                        }
                        Button("button.hide.debug") {
                            showDebugMenu = false
                            tapCount = 0
                            hapticConfirm()
                        }
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                DismissToolbarButton(action: {dismiss()})
            }
            .onAppear {
                // Check notification status when view appears
                if notificationsEnabled {
                    UNUserNotificationCenter.current().getNotificationSettings { settings in
                        DispatchQueue.main.async {
                            self.notificationsEnabled = settings.authorizationStatus == .authorized ||
                            settings.authorizationStatus == .provisional ||
                            settings.authorizationStatus == .ephemeral
                        }
                    }
                }
            }
        }
        .accentColor(Color(UIColor(named: selectedAccentColor) ?? .green))
        .alert("title.dialog.notifications", isPresented: $showingNotificationPermissionAlert) {
            Button("button.dialog.settings", role: .none) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("button.dialog.cancelReset", role: .cancel) { }
        } message: {
            Text("message.dialog.notifications")
        }
    }
    
    // Request notification permission from the user
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, _ in
                        DispatchQueue.main.async {
                            self.notificationsEnabled = success
                        }
                    }
                case .denied:
                    self.showingNotificationPermissionAlert = true
                    self.notificationsEnabled = false
                case .authorized, .provisional, .ephemeral:
                    break
                @unknown default:
                    break
                }
            }
        }
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
