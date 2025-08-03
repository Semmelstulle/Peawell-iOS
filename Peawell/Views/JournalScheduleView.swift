//
//  JournalScheduleView.swift
//  Peawell
//
//  Created on 09.07.25.
//

import SwiftUI
import UserNotifications

struct JournalScheduleView: View {
    @State private var notificationsEnabled = false
    @State private var selectedDays: Set<Int> = []
    @State private var times: [Date] = [Self.defaultTime]

    @Environment(\.dismiss) private var dismiss

    static var defaultTime: Date {
        var components = DateComponents()
        components.hour = 18
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }

    var body: some View {
        Form {
            Section {
                Toggle("toggle.journal.notifications", isOn: $notificationsEnabled)
            }

            Section(
                header: Text("header.journal.days")
            ) {
                WeekdayPicker(selectedDays: $selectedDays)
            }

            Section(
                header: Text("header.journal.times")
            ) {
                TimePicker(times: $times, isUsedToEdit: true)
            }
        }
        .navigationTitle("title.journal.schedule")
        .onAppear {
            loadSettings()
        }
        // Save and update notifications whenever these states change
        .onChange(of: notificationsEnabled) { _ in saveSettings(); updateNotifications() }
        .onChange(of: selectedDays) { _ in saveSettings(); updateNotifications() }
        .onChange(of: times) { _ in saveSettings(); updateNotifications() }
    }

    private func updateNotifications() {
        if notificationsEnabled, !selectedDays.isEmpty, !times.isEmpty {
            scheduleReminders(for: selectedDays, at: times)
        } else {
            cancelJournalReminders()
        }
    }

    private func saveSettings() {
        UserDefaults.standard.set(notificationsEnabled, forKey: JournalSettingsKeys.notificationsEnabled)
        UserDefaults.standard.set(Array(selectedDays), forKey: JournalSettingsKeys.selectedDays)
        let timeIntervals = times.map { $0.timeIntervalSinceReferenceDate }
        UserDefaults.standard.set(timeIntervals, forKey: JournalSettingsKeys.times)
        UserDefaults.standard.synchronize()
    }

    private func loadSettings() {
        notificationsEnabled = UserDefaults.standard.bool(forKey: JournalSettingsKeys.notificationsEnabled)

        if let savedDays = UserDefaults.standard.array(forKey: JournalSettingsKeys.selectedDays) as? [Int] {
            selectedDays = Set(savedDays)
        } else {
            selectedDays = []
        }

        if let savedTimes = UserDefaults.standard.array(forKey: JournalSettingsKeys.times) as? [TimeInterval] {
            let loadedTimes = savedTimes.map { Date(timeIntervalSinceReferenceDate: $0) }
            times = loadedTimes.isEmpty ? [Self.defaultTime] : loadedTimes
        } else {
            times = [Self.defaultTime]
        }

        updateNotifications()
    }

    // MARK: - Notification Scheduling

    func scheduleReminders(for days: Set<Int>, at times: [Date]) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if granted {
                        self.scheduleNotifications(center: center, days: days, times: times)
                    }
                }
                return
            }
            self.scheduleNotifications(center: center, days: days, times: times)
        }
    }

    private func scheduleNotifications(center: UNUserNotificationCenter, days: Set<Int>, times: [Date]) {
        cancelJournalReminders()

        for day in days {
            for time in times {
                var dateComponents = DateComponents()
                dateComponents.weekday = day // Apple weekday index

                let calendar = Calendar.current
                let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
                dateComponents.hour = timeComponents.hour
                dateComponents.minute = timeComponents.minute

                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

                let content = UNMutableNotificationContent()
                content.title = NSLocalizedString("notification.mood.title", comment: "")
                content.body = NSLocalizedString("notification.mood.body", comment: "")
                content.sound = .default

                let identifier = "journal-\(day)-\(dateComponents.hour ?? 0)-\(dateComponents.minute ?? 0)"
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                center.add(request) { error in
                    if let error = error {
                        print("Failed to schedule notification: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    func cancelJournalReminders() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let journalNotifications = requests.filter { $0.identifier.hasPrefix("journal-") }
            let identifiers = journalNotifications.map { $0.identifier }
            center.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
}

struct JournalSettingsKeys {
    static let notificationsEnabled = "JournalNotificationsEnabled"
    static let selectedDays = "JournalSelectedDays"
    static let times = "JournalReminderTimes"
}

#Preview {
    JournalScheduleView()
}
