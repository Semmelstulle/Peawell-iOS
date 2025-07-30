//
//  AddMedsSheetView.swift
//  Peawell
//
//  Created by Dennis on 19.04.23.
//

import SwiftUI

struct ModifyMedsSheetView: View {
    
    //  env variables
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedAccentColor") private var selectedAccentColor: String = "AccentColor"
    
    //  adds fetched data to scope
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Meds.medType, ascending: true)], animation: .default)
    var medsItems: FetchedResults<Meds>
    
    //  these define the user input field's default state
    @State var medName: String = ""
    @State var medAmount: String = ""
    @State var medUnit = "mg"
    @State var medKind = "longPill"
    var med: Meds?
    
    //  define possible selections
    @State var availableUnits = ["mg", "µg", "ml", "%"]
    @State var availableKinds = ["longPill", "roundPill", "drops", "inhaler"]
    let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    //  used for creating the schedule
    @State var medRemind: Bool = true
    @State private var selectedDays: Set<Int> = []
    @State private var times: Set<Date> = [Self.defaultTime]
    
    static var defaultTime: Date {
        var components = DateComponents()
        components.hour = 6
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    @State private var currentPage = 0
    @Namespace private var medKindHighlightNamespace
    
    //  Edit mode for time selection
    @State private var timeEditMode: EditMode = .inactive
    @State private var isAddingTime = false
    @State private var isEditingTime = false
    @State private var editingTime: Date?
    @State private var editingTimeValue = Date()
    @State private var newTime = Date()
    
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
                    } else {saveMedsWithSchedule(
                        med: med,
                        medName: medName,
                        medAmount: medAmount,
                        medUnit: medUnit,
                        medKind: medKind,
                        medRemind: medRemind,
                        selectedDays: selectedDays,
                        selectedTimes: times
                    )
                    dismiss()
                    }
                }
            )
            .navigationTitle("title.modify.meds")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                DismissToolbarButton(action: {dismiss()})
            }
        }
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
            .scrollContentBackground(.hidden)
            Spacer()
        }
    }
    
    @ViewBuilder
    func remindersPage() -> some View {
        //VStack {
            Form {
                remindersToggle
                Section { // this is what i want to be able to swipe to delete schedule if there is more than one
                    WeekdayPicker(selectedDays: $selectedDays)
                    TimePicker(times: Binding<[Date]>(
                        get: { Array(times).sorted() },
                        set: { newArray in
                            times = Set(newArray)
                        }
                    ))
                }
                .listRowBackground(Color(.secondarySystemBackground))
            }
            .scrollContentBackground(.hidden)
            Spacer()
        //}
    }
    
    var medKindPicker: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                ZStack(alignment: .leading) {
                    // Animated highlight
                    highlightRow
                    // Icon row
                    iconRow
                }
                .padding(.horizontal, 2)
            }
        }
        .listRowBackground(Color(.secondarySystemBackground))
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
                .pickerStyle(.menu)
                .labelsHidden()
            }
        }
        .listRowBackground(Color(.secondarySystemBackground))
    }
    
    var nextButton: some View {
        Button(action: {
            withAnimation { currentPage = 1 }
        }) {
            Label("button.next", systemImage: "arrow.right")
                .padding(8)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
        }
        .buttonStyle(.borderedProminent)
        .padding()
        .disabled(medName.isEmpty || medAmount.isEmpty)
    }
    
    var remindersToggle: some View {
        Section {
            Toggle(isOn: $medRemind) {
                Text("toggle.reminders")
            }
        }
        .listRowBackground(Color(.secondarySystemBackground))
    }
    
    private func populateFields() {
        if let med = med {
            medName = med.medType ?? ""
            medAmount = med.medDose ?? ""
            medUnit = med.medUnit ?? "mg"
            medKind = med.medKind ?? "longPill"
            medRemind = med.medRemind
            //  Populate selectedDays and selectedTimes if schedule exists
            if let schedules = med.schedule as? Set<Schedules>, let schedule = schedules.first {
                if let days = schedule.dates as? Set<Int> {
                    selectedDays = days
                }
                if let timesSet = schedule.times as? Set<Date> {
                    times = timesSet
                }
            }
        }
    }
}

#Preview {
    ModifyMedsSheetView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
