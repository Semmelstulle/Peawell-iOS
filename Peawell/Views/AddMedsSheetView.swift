//
//  AddMedsSheetView.swift
//  Peawell
//
//  Created by Dennis on 19.04.23.
//

import SwiftUI

struct AddMedsSheetView: View {
    
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
        NavigationView() {
            Form {
                //  neccessary fields on the top
                Section(header: Text(NSLocalizedString("add.meds.header", comment: "tells the user fields below are neccessary"))) {
                    TextField(
                        "Medication name",
                        text: $medName,
                        prompt: Text(NSLocalizedString("add.meds.medName", comment: "ask for medication name"))
                    )
                    HStack {
                        TextField(
                            "Medication dose",
                            text: $medAmount,
                            prompt: Text(NSLocalizedString("add.meds.medDose", comment: "ask for medication dose"))
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
                        NSLocalizedString("add.meds.medKind", comment: "ask for medication type"),
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
                        Text(NSLocalizedString("add.meds.enale.reminder", comment: "Let user know this toggles use of reminder"))
                    }
                    if medRemind {
                        Button(action: {
                            showDaySelectionSheet = true
                        }) {
                            HStack {
                                Text(NSLocalizedString("add.reminder.days.of.week", comment: "Let user know here is where you select days of week"))
                                Spacer()
                                Text(selectedDays.isEmpty ? "Select days" : "\(selectedDays.count) days selected")
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
                                Text(NSLocalizedString("add.reminder.hours.and.minutes", comment: "Let user know here is where you select the time"))
                                Spacer()
                                Text(selectedTimes.isEmpty ? "Select times" : "\(selectedTimes.count) times selected")
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
                                Label(NSLocalizedString("module.add.meds", comment: "tells the user this screen is for adding meds"), systemImage: "plus")
                                    .frame(maxWidth: .infinity)
                                    .multilineTextAlignment(.center)
                            }
                        )
                    }
                }
                .listRowBackground(Color.accentColor.opacity(0.2))
            }
            .navigationTitle(NSLocalizedString("module.add.meds", comment: "tells the user this screen is for adding meds"))
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
            .navigationTitle("Select Days")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
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
                
                Button("Add Time") {
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
                    EditButton()
                }
            }
            .navigationTitle("Select Times")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
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
        AddMedsSheetView()
    }
}
