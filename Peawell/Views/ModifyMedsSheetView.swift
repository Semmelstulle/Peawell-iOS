//
//  ModifyMedsSheetView.swift
//  Peawell
//
//  Created by Dennis on 19.04.23.
//

import SwiftUI

struct MedSchedule: Identifiable, Equatable {
    let id = UUID()
    var days: Set<Int>
    var times: Set<Date>
}

struct ModifyMedsSheetView: View {
    // env variables
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedAccentColor") private var selectedAccentColor: String = "AccentColor"

    // adds fetched data to scope
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Meds.medType, ascending: true)], animation: .default)
    var medsItems: FetchedResults<Meds>

    // these define the user input field's default state
    @State var medName: String = ""
    @State var medAmount: String = ""
    @State var medUnit = "mg"
    @State var medKind = "longPill"
    var med: Meds?

    // define possible selections
    @State var availableUnits = ["mg", "µg", "ml", "%"]
    @State var availableKinds = ["longPill", "roundPill", "drops", "inhaler", "dissolvable"]
    let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

    // Multiple schedules
    @State private var schedules: [MedSchedule] = [MedSchedule(days: [], times: [Self.defaultTime])]

    static var defaultTime: Date {
        var components = DateComponents()
        components.hour = 6
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }

    @State private var currentPage = 0
    @Namespace private var medKindHighlightNamespace

    @State var medRemind: Bool = false

    var body: some View {
        NavigationStack {
            TabView(selection: $currentPage) {
                medDetailsPage()
                    .tag(0)
                remindersPage()
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .background(Color.clear)
            AccessoryProminentButtonBig(
                title: currentPage == 0 ? NSLocalizedString("button.next", comment: "") : NSLocalizedString("button.meds.save", comment: ""),
                systemImage: "square.and.pencil",
                action: {
                    if currentPage == 0 {
                        withAnimation {
                            currentPage = 1
                        }
                    } else {
                        if !medName.isEmpty && !medAmount.isEmpty {
                            saveMedsWithSchedules(
                                med: med,
                                medName: medName,
                                medAmount: medAmount,
                                medUnit: medUnit,
                                medKind: medKind,
                                medRemind: medRemind,
                                schedules: schedules.filter { !$0.days.isEmpty && !$0.times.isEmpty }
                            )
                            dismiss()
                        }
                    }
                }
            )
            .navigationTitle("title.modify.meds")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                DismissToolbarButton(action: { dismiss() })
            }
        }
        .background(Color(.systemGroupedBackground))
        .accentColor(Color(UIColor(named: selectedAccentColor) ?? .green))
        .onAppear {
            populateFields()
        }
    }

    @ViewBuilder
    func medDetailsPage() -> some View {
        VStack {
            Form {
                medKindPicker
                medDetailsSection
            }
            Spacer()
        }
    }

    @ViewBuilder
    func remindersPage() -> some View {
        Form {
            remindersToggle

            ForEach(schedules.indices, id: \.self) { index in
                Section {
                    WeekdayPicker(selectedDays: $schedules[index].days)
                    TimePicker(times: Binding<[Date]>(
                        get: { Array(schedules[index].times).sorted() },
                        set: { newArray in schedules[index].times = Set(newArray) }
                    ), isUsedToEdit: true)
                    if index > 0 {
                        Button(role: .destructive) {
                            withAnimation {
                                deleteSchedule(at: index)
                            }
                        } label: {
                            Label("button.removeSchedule", systemImage: "minus.circle")
                        }
                    }
                }
                .listRowBackground(Color(.secondarySystemGroupedBackground))
            }
            
            Button {
                withAnimation {
                    schedules.append(MedSchedule(days: [], times: [Self.defaultTime]))
                }
            } label: {
                Label("button.addSchedule", systemImage: "plus.circle")
            }
            .listRowBackground(Color(.secondarySystemGroupedBackground))
        }
        Spacer()
    }

    func deleteSchedule(at index: Int) {
        schedules.remove(at: index)
        if schedules.isEmpty {
            schedules = [MedSchedule(days: [], times: [Self.defaultTime])]
        }
    }

    var medKindPicker: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                ZStack(alignment: .leading) {
                    highlightRow
                    iconRow
                }
                .padding(.horizontal, 2)
            }
        }
        .listRowBackground(Color(.secondarySystemGroupedBackground))
    }

    var highlightRow: some View {
        HStack(spacing: 20) {
            ForEach(availableKinds, id: \.self) { kind in
                if medKind == kind {
                    RoundedRectangle(cornerRadius: Constants.cornerRadiusSecondary)
                        .fill(Color("\(kind)Color"))
                        .frame(width: 56, height: 56)
                        .matchedGeometryEffect(id: "medKindHighlight", in: medKindHighlightNamespace)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: medKind)
                } else {
                    Spacer().frame(width: 56)
                }
            }
        }
        .frame(height: 56)
    }

    var iconRow: some View {
        HStack(spacing: 20) {
            ForEach(availableKinds, id: \.self) { kind in
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        medKind = kind
                    }
                }) {
                    Image(kind)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 42, height: 42)
                        .padding(7)
                        .frame(width: 56, height: 56)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(height: 56)
    }

    var medDetailsSection: some View {
        Section(header: Text("section.header.meds")) {
            TextField(
                "prompt.meds.name",
                text: $medName,
                prompt: Text("prompt.meds.name")
            )
            HStack {
                TextField(
                    "prompt.meds.amount",
                    text: $medAmount,
                    prompt: Text("prompt.meds.amount")
                )
                .keyboardType(.decimalPad)
                Picker(
                    "",
                    selection: $medUnit
                ) {
                    ForEach(availableUnits, id: \.self) { item in
                        Text(item)
                    }
                }
                .padding(.vertical, -8)
                .pickerStyle(.menu)
                .labelsHidden()
            }
        }
        .listRowBackground(Color(.secondarySystemGroupedBackground))
    }

    var remindersToggle: some View {
        Section {
            Toggle(isOn: $medRemind) {
                Text("toggle.reminders")
            }
            .onChange(of: medRemind) { _ in
                updateMedNotifications(enabled: medRemind, schedules: schedules, medName: medName)
            }
            .onChange(of: schedules) { _ in
                updateMedNotifications(enabled: medRemind, schedules: schedules, medName: medName)
            }
        }
        .listRowBackground(Color(.secondarySystemGroupedBackground))
    }

    private func populateFields() {
        if let med = med {
            medName = med.medType ?? ""
            medAmount = med.medDose ?? ""
            medUnit = med.medUnit ?? "mg"
            medKind = med.medKind ?? "longPill"
            medRemind = med.medRemind
            if let scheduleSet = med.schedule as? Set<Schedules> {
                self.schedules = scheduleSet.compactMap { schedule in
                    guard
                        let days = schedule.dates as? Set<Int>,
                        let timesSet = schedule.times as? Set<Date>
                    else { return nil }
                    return MedSchedule(days: days, times: timesSet)
                }
                .sorted { $0.id.uuidString < $1.id.uuidString }
                if self.schedules.isEmpty {
                    self.schedules = [MedSchedule(days: [], times: [Self.defaultTime])]
                }
            } else {
                self.schedules = [MedSchedule(days: [], times: [Self.defaultTime])]
            }
        } else {
            self.schedules = [MedSchedule(days: [], times: [Self.defaultTime])]
        }
    }
}

#Preview {
    ModifyMedsSheetView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
