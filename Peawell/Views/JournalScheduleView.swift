//
//  JournalScheduleView.swift
//  Peawell
//
//  Created on 09.07.25.
//

import SwiftUI
import UserNotifications

struct JournalScheduleView: View {
    // Notification settings
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("journalingRemindersEnabled") private var journalingRemindersEnabled = false
    @AppStorage("journalingSelectedDays") private var journalingSelectedDaysData: Data = {
        // Default to first weekday (depends on system settings)
        let defaultSelectedDay = Set<Int>([0]) // First day in the ordered array
        return try! JSONEncoder().encode(defaultSelectedDay)
    }()
    @AppStorage("journalingSelectedTimes") private var journalingSelectedTimesData: Data = {
        let defaultTime = Set([Calendar.current.date(from: DateComponents(hour: 18, minute: 0))!]) // 6 PM by default
        return try! JSONEncoder().encode(defaultTime)
    }()
    
    @State private var selectedDays = Set<Int>()
    @State private var selectedTimes = Set<Date>()
    @State private var hasUnsavedChanges = false
    
    @State private var showingNotificationPermissionAlert = false
    
    // Array of full weekday names, ordered according to the user's calendar settings
    private var weekdays: [String] = {
        let calendar = Calendar.current
        var weekdays = calendar.weekdaySymbols
        
        // Adjust array based on first day of week setting
        if calendar.firstWeekday > 1 {
            let firstDayIndex = calendar.firstWeekday - 1
            let firstPart = Array(weekdays[firstDayIndex...])
            let secondPart = Array(weekdays[..<firstDayIndex])
            weekdays = firstPart + secondPart
        }
        
        return weekdays
    }()
    
    private enum Constants {
        // Get properly ordered weekday symbols based on user's first day of week preference
        static let localizedWeekdaySymbols: [String] = {
            let calendar = Calendar.current
            var weekdaySymbols = calendar.veryShortWeekdaySymbols
            
            // Adjust array based on first day of week setting (1 = Sunday, 2 = Monday, etc.)
            if calendar.firstWeekday > 1 {
                // For example, if firstWeekday is 2 (Monday), rotate array so Monday is first
                let firstDayIndex = calendar.firstWeekday - 1
                let firstPart = Array(weekdaySymbols[firstDayIndex...])
                let secondPart = Array(weekdaySymbols[..<firstDayIndex])
                weekdaySymbols = firstPart + secondPart
            }
            
            return weekdaySymbols
        }()
    }
    
    var body: some View {
            Form {
                Toggle(
                    isOn: $journalingRemindersEnabled,
                    label: {Text("label.jounrnal.reminders")}
                )
                .onChange(of: journalingRemindersEnabled) { newValue in
                    if newValue {
                        scheduleJournalingReminders()
                    } else {
                        cancelJournalingReminders()
                    }
                }
                
                if journalingRemindersEnabled {
                    daySelectionSection
                    timeSelectionSection
                        
                }
            }
        .navigationTitle("title.journal.schedule")
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
        .onAppear {
            // Load saved data
            loadSelectedData()
            
            // Check notification status when view appears
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    self.notificationsEnabled = settings.authorizationStatus == .authorized ||
                                               settings.authorizationStatus == .provisional ||
                                               settings.authorizationStatus == .ephemeral
                    
                    // If notifications aren't enabled but reminders are, show alert
                    if !self.notificationsEnabled && self.journalingRemindersEnabled {
                        self.showingNotificationPermissionAlert = true
                    }
                }
            }
        }
        .onDisappear {
            if hasUnsavedChanges {
                saveSelectedDays()
                saveSelectedTimes()
                if journalingRemindersEnabled {
                    scheduleJournalingReminders()
                }
                hasUnsavedChanges = false
            }
        }
    }
    
    // Day selection section with circular day buttons
    var daySelectionSection: some View {
        Section(header: Text("title.daySelection")) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Constants.localizedWeekdaySymbols.indices, id: \.self) { idx in
                        let isSelected = selectedDays.contains(idx)
                        Button(action: {
                            if isSelected {
                                selectedDays.remove(idx)
                            } else {
                                selectedDays.insert(idx)
                            }
                            hasUnsavedChanges = true
                        }) {
                            Text(Constants.localizedWeekdaySymbols[idx])
                                .font(.headline)
                                .frame(width: 36, height: 36)
                                .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(isSelected ? Color.accentColor : Color.secondary, lineWidth: isSelected ? 2 : 1)
                                )
                                .foregroundColor(isSelected ? .accentColor : .primary)
                                .accessibilityLabel(Text(weekdays[idx]))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
            }
        }
    }
    
    // Time selection section with multiple times
    var timeSelectionSection: some View {
        Section(header: HStack {
            Text("title.timeSelection")
            Spacer()
            Button(action: {
                let calendar = Calendar.current
                let now = Date()
                let nextHour = calendar.nextDate(after: now, matching: DateComponents(minute: 0, second: 0), matchingPolicy: .nextTime) ?? now
                var candidate = nextHour
                var attempts = 0
                while selectedTimes.contains(candidate) && attempts < 24 {
                    candidate = calendar.date(byAdding: .hour, value: 1, to: candidate) ?? candidate
                    attempts += 1
                }
                selectedTimes.insert(candidate)
                hasUnsavedChanges = true
            }) {
                Image(systemName: "plus.circle.fill").font(.title2)
            }
        }) {
            if selectedTimes.isEmpty {
                Text("title.noSelection")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(Array(selectedTimes).sorted(by: { $0 < $1 }), id: \.self) { time in
                    HStack {
                        DatePicker("", selection: Binding(
                            get: { time },
                            set: { newValue in
                                selectedTimes.remove(time)
                                // Normalize to hour/minute only
                                let calendar = Calendar.current
                                let components = calendar.dateComponents([.hour, .minute], from: newValue)
                                if let normalized = calendar.date(from: components) {
                                    selectedTimes.insert(normalized)
                                    hasUnsavedChanges = true
                                }
                            }
                        ), displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        Spacer()
                        Button(action: {
                            selectedTimes.remove(time)
                            hasUnsavedChanges = true
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                        }
                    }
                }
            }
        }
    }
    
    // Load selected days and times from AppStorage
    private func loadSelectedData() {
        do {
            selectedDays = try JSONDecoder().decode(Set<Int>.self, from: journalingSelectedDaysData)
            selectedTimes = try JSONDecoder().decode(Set<Date>.self, from: journalingSelectedTimesData)
        } catch {
            // Set defaults if there's an error
            selectedDays = [0] // First day in the UI's ordered array (not Monday)
            if let defaultTime = Calendar.current.date(from: DateComponents(hour: 18, minute: 0)) {
                selectedTimes = [defaultTime]
            }
            saveSelectedDays()
            saveSelectedTimes()
        }
    }
    
    // Save selected days to AppStorage
    private func saveSelectedDays() {
        do {
            journalingSelectedDaysData = try JSONEncoder().encode(selectedDays)
        } catch {
        }
    }
    
    // Save selected times to AppStorage
    private func saveSelectedTimes() {
        do {
            journalingSelectedTimesData = try JSONEncoder().encode(selectedTimes)
        } catch {
        }
    }
    
    // Schedule journaling reminders based on selected days and times
    private func scheduleJournalingReminders() {
        // Cancel any existing reminders first
        cancelJournalingReminders()
        
        // Ensure we have days and times selected
        guard !selectedDays.isEmpty, !selectedTimes.isEmpty else {
            return
        }
        
        // Create the notification content
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notification.mood.title", comment: "")
        content.body = NSLocalizedString("notification.mood.body", comment: "")
        content.sound = .default
        
        // Create and schedule a notification for each day and time combination
        let calendar = Calendar.current
        for day in selectedDays {
            for time in selectedTimes {
                let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
                var dateComponents = DateComponents()
                
                // day is 0-indexed in UI. Convert to Calendar weekday (1-7, firstWeekday).  
                // weekday = ((day + calendar.firstWeekday - 1) % 7) + 1
                let weekdayIndex = ((day + calendar.firstWeekday - 1) % 7) + 1
                dateComponents.weekday = weekdayIndex // Calendar weekdays are 1-7 with 1=Sunday
                dateComponents.hour = timeComponents.hour
                dateComponents.minute = timeComponents.minute
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                
                // Create unique identifier for each day and time combination
                let identifier = "journalingReminder-day\(day)-hour\(timeComponents.hour ?? 0)-minute\(timeComponents.minute ?? 0)"
                
                // Create the request
                let request = UNNotificationRequest(
                    identifier: identifier,
                    content: content,
                    trigger: trigger
                )
                
                // Schedule the notification
                UNUserNotificationCenter.current().add(request) { error in
                    if error != nil {
                    }
                }
            }
        }
    }
    
    // Cancel all journaling reminders
    private func cancelJournalingReminders() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiers = requests
                .filter { $0.identifier.starts(with: "journalingReminder") }
                .map { $0.identifier }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    
    // Legacy support for old methods
    private func scheduleJournalingReminder() {
        scheduleJournalingReminders()
    }
    
    private func cancelJournalingReminder() {
        cancelJournalingReminders()
    }
}

#Preview {
    NavigationStack {
        JournalScheduleView()
    }
}
