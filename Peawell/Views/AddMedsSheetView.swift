//
//  AddMedsSheetView.swift
//  Peawell
//
//  Created by Dennis on 19.04.23.
//

import SwiftUI

struct AddMedsSheetView: View {
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Meds.medType, ascending: true)], animation: .default)
    var medsItems: FetchedResults<Meds>

    //  these define the user input field's empty state
    @State var medName: String = ""
    @State var medAmount: String = ""
    @State var medUnit = "mg"
    @State var availableUnits = ["mg", "µg"]
    @State var medKind = "Long pill"
    @State var availableKinds = ["Long pill", "Round pill", "Drops"]
    @State var medReminders = Date()
    @State var selectedDays: Int = 0
    @State var hour: Int = 8
    @State var minute: Int = 0
    
    var body: some View {
        NavigationView() {
            Form {
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
                            //  "Pick the unit of your medication",
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
                Section {
                    DayOfWeekPicker(selectedDays: $selectedDays)
                    TimePickerView(hour: $hour, minute: $minute)
                }
            }
            .navigationTitle(NSLocalizedString("module.add.meds", comment: "tells the user this screen is for adding meds"))
            .toolbar {
                Button(
                    action: {
                        if medName != "" && medAmount != "" && medKind != "" {
                            saveMeds(medName: medName, medAmount: medAmount, medUnit: medUnit, medKind: medKind)
                            medName = ""
                            medAmount = ""
                            hapticConfirm()
                        }
                    }, label: {
                        Label(NSLocalizedString("module.add.meds", comment: "tells the user this screen is for adding meds"), systemImage: "plus")
                    }
                )
            }
        }
    }
}

struct DayOfWeekPicker: View {
    @Binding var selectedDays: Int
    let daysAbbreviated = ["M", "T", "W", "T", "F", "S", "S"]
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<7) { index in
                let mask = 1 << index
                Circle()
                    .fill(selectedDays & mask != 0 ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(Text(daysAbbreviated[index]).foregroundColor(.white))
                    .onTapGesture {
                        selectedDays ^= mask // Toggle this day
                    }
            }
        }
        .padding()
    }
}

struct TimePickerView: View {
    @Binding var hour: Int
    @Binding var minute: Int
    
    var body: some View {
        HStack {
            Picker("Hour", selection: $hour) {
                ForEach(0..<24) { hour in
                    Text("\(hour)").tag(hour)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: 100)
            .clipped()
            
            Text(":")
            
            Picker("Minute", selection: $minute) {
                ForEach(0..<60) { minute in
                    Text(String(format: "%02d", minute)).tag(minute)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: 100)
            .clipped()
        }
    }
}

struct AddMedsSheetView_Previews: PreviewProvider {
    static var previews: some View {
        AddMedsSheetView()
    }
}
