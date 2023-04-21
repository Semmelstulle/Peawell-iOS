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
    @State var medReminders = Date()
    @State var showReminderPicker: Bool = false

    var body: some View {
        NavigationView() {
            Form {
                Section(header: Text("Necessary info")) {
                    TextField(
                        "Medication name",
                        text: $medName,
                        prompt: Text("What is your medication called?")
                    )
                    HStack {
                        TextField(
                            "Medication dose",
                            text: $medAmount,
                            prompt: Text("How much should you take?")
                        )
                        .keyboardType(.decimalPad)
                        Picker(
                            "",
                            //"Pick the unit of your medication",
                            selection: $medUnit
                        ) {
                            ForEach(availableUnits, id: \.self) { item in
                                Text(item)
                            }
                        }
                        .labelsHidden()
                    }
                }
                Section(header: Text("Reminders")) {
                    Button(
                        action: {
                            withAnimation(.easeOut(duration: 0.2)) {
                                showReminderPicker = true
                            }
                        }, label: {
                            Text("Add reminder")
                        }

                    )
                    if showReminderPicker == true {
                        DatePicker(
                            "When do you want to be reminded?",
                            selection: $medReminders,
                            displayedComponents: .hourAndMinute
                        )
                    }
                }
                Button(
                    action: {
                        if medName != "" && medAmount != "" {
                            saveMeds(medName: medName, medAmount: medAmount, medUnit: medUnit)
                            medName = ""
                            medAmount = ""
                            hapticConfirm()
                        }
                    }, label: {
                        Label("Add medication", systemImage: "plus")
                    }
                )
            }
            .navigationTitle("Add medication")
        }
    }
}

struct AddMedsSheetView_Previews: PreviewProvider {
    static var previews: some View {
        AddMedsSheetView()
    }
}
