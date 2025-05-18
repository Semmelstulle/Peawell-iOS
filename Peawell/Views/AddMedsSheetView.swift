//
//  AddMedsSheetView.swift
//  Peawell
//
//  Created by Dennis on 19.04.23.
//

import SwiftUI

struct AddMedsSheetView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Meds.medType, ascending: true)], animation: .default)
    var medsItems: FetchedResults<Meds>

    //  these define the user input field's empty state
    @State var medName: String = ""
    @State var medAmount: String = ""
    @State var medUnit = "mg"
    @State var availableUnits = ["mg", "µg"]
    @State var medKind = "Long pill"
    @State var availableKinds = ["longPill", "roundPill", "drops", "inhaler"]
    
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
    
    //  Move function here to make it work in preview
    private func saveMeds(medName: String, medAmount: String, medUnit: String, medKind: String) {
        let newMed = Meds(context: viewContext)
        newMed.medType = medName
        newMed.medDose = medAmount
        newMed.medUnit = medUnit
        newMed.medKind = medKind
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving medication: \(error.localizedDescription)")
        }
    }
}

struct AddMedsSheetView_Previews: PreviewProvider {
    static var previews: some View {
        AddMedsSheetView()
    }
}
