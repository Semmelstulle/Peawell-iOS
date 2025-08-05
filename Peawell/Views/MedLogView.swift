//
//  MedLogView.swift
//  Peawell
//
//  Created by dennis on 14.06.24.
//

import SwiftUI

struct MedLogView: View {
    
    // Fetch requests
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Meds.medType, ascending: true)],
        animation: .default)
    var medsItems: FetchedResults<Meds>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LogTimeMeds.logTimes, ascending: false)],
        animation: .default)
    var logEntries: FetchedResults<LogTimeMeds>
    
    @State private var editingMed: Meds?
    @State private var showingDeleteAlert: Bool = false
    
    @State private var searchText: String = ""
    @State private var filteredLogEntries: [LogTimeMeds] = []
    
    var body: some View {
        List {
            medicationListSection
            medicationHistorySection()
        }
        .searchable(text: $searchText, prompt: "search.meds")
        .onAppear {
            filterLogs()
        }
        .onChange(of: searchText) { _ in
            filterLogs()
        }
        .navigationTitle("title.med")
        .sheet(item: $editingMed) { med in
            ModifyMedsSheetView(med: med)
                .presentationDragIndicator(.hidden)
        }
    }
    
    private func filterLogs() {
        // When no search text, show all logs
        guard !searchText.isEmpty else {
            filteredLogEntries = Array(logEntries)
            return
        }

        // Try parse date from search text for date filtering
        var datePredicate: ((Date) -> Bool)? = nil
        if let searchDate = dateFormatter.date(from: searchText) {
            let startOfDay = Calendar.current.startOfDay(for: searchDate)
            let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
            datePredicate = { logDate in
                logDate >= startOfDay && logDate < endOfDay
            }
        }

        filteredLogEntries = logEntries.filter { log in
            // Unwrap med properties for easier access
            let med = log.medication

            let matchesName = med?.medType?.localizedCaseInsensitiveContains(searchText) ?? false
            let matchesKind = med?.medKind?.localizedCaseInsensitiveContains(searchText) ?? false
            let matchesDose = med?.medDose?.localizedCaseInsensitiveContains(searchText) ?? false

            let matchesDate = (log.logTimes != nil && datePredicate?(log.logTimes!) == true)

            return matchesName || matchesKind || matchesDose || matchesDate
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}

// MARK: - Components
private extension MedLogView {
    var medicationListSection: some View {
        Section(header: Text("section.header.medList")) {
            ForEach(medsItems) { item in
                NavigationLink {
                    medDetailView(item: item)
                } label: {
                    medListRowView(item: item)
                }
                .swipeActions(allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        trashItem(objectID: item.objectID)
                    } label: {
                        Image(systemName: "trash")
                    }
                    
                    Button {
                        editingMed = item
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
        }
    }
    
    func medListRowView(item: Meds) -> some View {
        HStack(spacing: Constants.stackSpacing) {
            let medColorName = "\(item.medKind ?? "longPill")Color"
            Image(item.medKind ?? "")
                .resizable()
                .frame(width: 20, height: 20)
                .padding(6)
                .background(Color(medColorName))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Text(item.medType ?? "")
            Spacer()
            Text("\(item.medDose ?? "") \(item.medUnit ?? "")")
                .opacity(0.4)
        }
    }
    
    @ViewBuilder
    func medDetailView(item: Meds) -> some View {
        let medColorName = "\(item.medKind ?? "longPill")Color"
        List {
            Section {
                HStack {
                    Spacer()
                    Image(item.medKind ?? "")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .padding()
                    Spacer()
                }
                .listRowBackground(Color(medColorName))
            }

            Section {
                HStack {
                    Text("prompt.meds.amount")
                    Spacer()
                    Text(item.medDose ?? "")
                        .font(.title3)
                        .foregroundColor(Color.secondary)
                    Text(item.medUnit ?? "")
                        .font(.title3)
                        .foregroundColor(Color.secondary)
                }
            }

            if item.medRemind, let schedulesSet = item.schedule as? Set<Schedules>, !schedulesSet.isEmpty {
                scheduleSection(schedulesSet: schedulesSet)
            }
            medicationHistorySection(for: item)
        }
        .navigationTitle(Text(item.medType ?? ""))
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    editingMed = item
                } label: {
                    Image(systemName: "square.and.pencil")
                }
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                }
                .confirmationDialog("", isPresented: $showingDeleteAlert) {
                    Button("button.dialog.cancelReset", role: .cancel) {
                        showingDeleteAlert = false
                    }
                    Button("button.dialog.confirmReset", role: .destructive) {
                        trashItem(objectID: item.objectID)
                    }
                }
            }
        }
    }

    func scheduleSection(schedulesSet: Set<Schedules>) -> some View {
        ForEach(Array(schedulesSet), id: \.self) { schedule in
            Section {
                WeekdayPicker(selectedDays: .constant(extractDays(from: schedule)))
                
                TimePicker(times: .constant(extractTimes(from: schedule).sorted()), isUsedToEdit: false)
            }
        }
    }
    
    func medicationHistorySection(for med: Meds? = nil) -> some View {
        let filteredLogs: [LogTimeMeds]
        if let med = med {
            filteredLogs = logEntries
                .filter { $0.medication == med }
                .sorted { ($0.logTimes ?? Date.distantPast) > ($1.logTimes ?? Date.distantPast) }
        } else {
            filteredLogs = filteredLogEntries.sorted { ($0.logTimes ?? Date.distantPast) > ($1.logTimes ?? Date.distantPast) }
        }
        
        return Section(header: Text("section.header.medHistory")) {
            if filteredLogs.isEmpty {
                Text("hint.noData")
                    .foregroundColor(.secondary)
            } else {
                ForEach(filteredLogs, id: \.self) { item in
                    HStack(spacing: Constants.stackSpacing) {
                        let medColorName = "\(item.medication?.medKind ?? "longPill")Color"
                        Image(item.medication?.medKind ?? "longPill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(6)
                            .background(Color(medColorName))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        Text(item.medication?.medType ?? "Unknown Medication")
                        Spacer()
                        if let logTime = item.logTimes {
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(logTime.formatted(date: .abbreviated, time: .omitted))
                                Text(logTime.formatted(date: .omitted, time: .shortened))
                            }
                            .opacity(0.4)
                        }
                    }
                    .swipeActions(allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            trashItem(objectID: item.objectID)
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
        }
    }

    func extractDays(from schedule: Schedules) -> Set<Int> {
        if let days = schedule.dates as? Set<Int> {
            return days
        }
        if let daysNSNumber = schedule.dates {
            return daysNSNumber.compactMap { $0 as? Int }.reduce(into: Set<Int>()) { $0.insert($1) }
        }
        return Set<Int>()
    }
    
    func extractTimes(from schedule: Schedules) -> [Date] {
        if let times = schedule.times as? Set<Date> {
            return Array(times)
        }
        if let timesNSNumber = schedule.times {
            return timesNSNumber.compactMap { $0 as? Date }
        }
        return []
    }
}

#Preview {
    MedLogView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
