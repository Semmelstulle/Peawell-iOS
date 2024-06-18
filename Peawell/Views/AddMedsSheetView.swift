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
    @State var showReminderPicker: Bool = false
    
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
            .navigationTitle(NSLocalizedString("module.add.meds", comment: "tells the user this screen is for adding meds"))
        }
    }
}

struct AddMedsSheetView_Previews: PreviewProvider {
    static var previews: some View {
        AddMedsSheetView()
    }
}
