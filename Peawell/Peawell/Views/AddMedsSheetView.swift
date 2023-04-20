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

    var body: some View {
        NavigationView() {
            ScrollView() {
                VStack() {
                    TextField(
                        "Medication name",
                        text: $medName,
                        prompt: Text("What is your medication called?")
                    )
                    .padding()
                    .background(Color.secondarySystemBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    HStack() {
                        TextField(
                            "Medication dose",
                            text: $medAmount,
                            prompt: Text("Dose here")
                        )
                        .padding()
                        .background(Color.secondarySystemBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .keyboardType(.decimalPad)
                        Picker(
                            "Select unit type",
                            selection: $medUnit
                        ) {
                            ForEach(availableUnits, id: \.self) { item in
                                Text(item)
                            }
                        }
                            .padding(10)
                            .pickerStyle(MenuPickerStyle())
                            .background(Color.secondarySystemBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                }
                .padding()
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
                .padding()
                .background(Color.secondarySystemBackground)
                .foregroundColor(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 15))
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
