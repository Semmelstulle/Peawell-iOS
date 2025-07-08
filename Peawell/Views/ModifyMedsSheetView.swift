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
    @State var availableUnits = ["mg", "µg", "ml"]
    @State var availableKinds = ["longPill", "roundPill", "drops", "inhaler"]
    let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    //  used for creating the schedule
    @State var medRemind: Bool = true
    @State private var selectedDays: Set<Int> = []
    @State private var selectedTimes: Set<Date> = []
    @State private var showDaySelectionSheet = false
    @State private var showTimeSelectionSheet = false
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
            VStack {
                TabView(selection: $currentPage) {
                    // Page 1: Med details
                    VStack {
                        Form {
                            // Visual medKind picker section
                            Section {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    ZStack(alignment: .leading) {
                                        // Animated highlight
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
                                        // Icon row
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
                                    .padding(.horizontal, 2)
                                }
                            }
                            .listRowBackground(Color(.tertiarySystemGroupedBackground))
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
                            .listRowBackground(Color(.tertiarySystemGroupedBackground))
                        }
                        .scrollContentBackground(.hidden)
                        Spacer()
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
                    .tag(0)
                    // Page 2: Reminders
                    VStack {
                        Form {
                            Section {
                                Toggle(isOn: $medRemind) {
                                    Text("toggle.reminders")
                                }
                            }
                            .listRowBackground(Color(.tertiarySystemGroupedBackground))
                            if medRemind {
                                Section(header: Text("title.daySelection")) {
                                    HStack(spacing: 12) {
                                        ForEach(Constants.localizedWeekdaySymbols.indices, id: \.self) { idx in
                                            let isSelected = selectedDays.contains(idx)
                                            Button(action: {
                                                if isSelected {
                                                    selectedDays.remove(idx)
                                                } else {
                                                    selectedDays.insert(idx)
                                                }
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
                                    .padding(.vertical, 4)
                                }
                                .listRowBackground(Color(.tertiarySystemGroupedBackground))
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
                                    }) {
                                        Image(systemName: "plus.circle.fill").font(.title2)
                                    }
                                    .accessibilityLabel(Text("button.addTime"))
                                }) {
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
                                                    }
                                                }
                                            ), displayedComponents: .hourAndMinute)
                                            .datePickerStyle(.compact)
                                            .labelsHidden()
                                            Spacer()
                                            Button(action: {
                                                selectedTimes.remove(time)
                                            }) {
                                                Image(systemName: "minus.circle.fill")
                                                    .foregroundColor(.red)
                                                    .font(.title2)
                                            }
                                        }
                                    }
                                }
                                .listRowBackground(Color(.tertiarySystemGroupedBackground))
                            }
                        }
                        .scrollContentBackground(.hidden)
                        Spacer()
                        Button(
                            action: {
                                //  create a new medication with schedule
                                saveMedsWithSchedule(
                                    med: med,
                                    medName: medName,
                                    medAmount: medAmount,
                                    medUnit: medUnit,
                                    medKind: medKind,
                                    medRemind: medRemind,
                                    selectedDays: selectedDays,
                                    selectedTimes: selectedTimes
                                )
                                dismiss()
                            }, label: {
                                Label("button.save.meds", systemImage: "plus")
                                    .padding(8)
                                    .frame(maxWidth: .infinity)
                                    .multilineTextAlignment(.center)
                            }
                        )
                        .buttonStyle(.borderedProminent)
                        .padding()
                        .disabled(medName.isEmpty || medAmount.isEmpty)
                    }
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .background(Color.clear)
            .navigationTitle("title.modify.meds")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if #available(iOS 26.0, *) {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                } else {
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
        .onAppear {
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
                    if let times = schedule.times as? Set<Date> {
                        selectedTimes = times
                    }
                }
            }
        }
    }
}

#Preview {
    ModifyMedsSheetView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
