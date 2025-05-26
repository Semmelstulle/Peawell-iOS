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
    
    var body: some View {
        NavigationStack {
            Form {
                //  neccessary fields on the top
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
                        .labelsHidden()
                    }
                    Picker(
                        "suffix.picker.medKind",
                        selection: $medKind
                    ) {
                        ForEach(availableKinds, id: \.self) { item in
                            Text(item)
                        }
                    }
                }
                //  toggle so the schedule is only shown if relevant
                Section {
                    Toggle(isOn: $medRemind) {
                        Text("toggle.reminders")
                    }
                    if medRemind {
                        Button(action: {
                            showDaySelectionSheet = true
                        }) {
                            HStack {
                                Text("title.daySelection")
                                Spacer()
                                Text(selectedDays.isEmpty ? "none.days.selected" : "\(selectedDays.count) x.days.selected")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .sheet(isPresented: $showDaySelectionSheet) {
                            DaySelectionView(selectedDays: $selectedDays)
                        }
                        
                        Button(action: {
                            showTimeSelectionSheet = true
                        }) {
                            HStack {
                                Text("title.timeSelection")
                                Spacer()
                                Text(selectedTimes.isEmpty ? "none.times.selected" : "\(selectedTimes.count) x.times.selected")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .sheet(isPresented: $showTimeSelectionSheet) {
                            TimeSelectionView(selectedTimes: $selectedTimes)
                        }
                    }
                }
                Section {
                    if !medName.isEmpty && !medAmount.isEmpty {
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
                                    .frame(maxWidth: .infinity)
                                    .multilineTextAlignment(.center)
                            }
                        )
                    }
                }
                .listRowBackground(Color.accentColor.opacity(0.3))
            }
            .navigationTitle("title.modify.meds")
            .navigationBarTitleDisplayMode(.inline)
            //  just a fancy dismiss button
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
        .onAppear {
            if let med = med {
                medName = med.medType ?? ""
                medAmount = med.medDose ?? ""
                medUnit = med.medUnit ?? "mg"
                medKind = med.medKind ?? "longPill"
                medRemind = med.medRemind
                // Populate selectedDays and selectedTimes if schedule exists
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

struct DaySelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDays: Set<Int>
    
    let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(0..<weekdays.count, id: \.self) { index in
                    Button(action: {
                        if selectedDays.contains(index) {
                            selectedDays.remove(index)
                        } else {
                            selectedDays.insert(index)
                        }
                    }) {
                        HStack {
                            Text(weekdays[index])
                            Spacer()
                            if selectedDays.contains(index) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("title.daySelection")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("button.done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TimeSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTimes: Set<Date>
    @State private var newTime = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("", selection: $newTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                
                Button("button.addTime") {
                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.hour, .minute], from: newTime)
                    if let normalizedTime = calendar.date(from: components) {
                        selectedTimes.insert(normalizedTime)
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()
                
                List {
                    ForEach(Array(selectedTimes), id: \.self) { time in
                        HStack {
                            Text(time.formatted(date: .omitted, time: .shortened))
                            Spacer()
                        }
                    }
                    .onDelete(perform: deleteTime)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("button.done") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
            }
            .navigationTitle("title.timeSelection")
        }
    }
    
    func deleteTime(at offsets: IndexSet) {
        let timesArray = Array(selectedTimes)
        for index in offsets {
            selectedTimes.remove(timesArray[index])
        }
    }
}


struct AddMedsSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ModifyMedsSheetView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
