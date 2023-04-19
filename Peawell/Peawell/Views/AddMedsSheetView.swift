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

    var body: some View {
        NavigationView() {
            ScrollView() {
                TextField(
                    text: $medName,
                    prompt: Text("What is your medication called?")
                ) {}
                    .padding()
                    .background(Color.secondarySystemBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding()
                HStack() {
                    TextField(
                        text: $medAmount,
                        prompt: Text("Dose here")
                    ) {}
                        .padding()
                        .background(Color.secondarySystemBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .keyboardType(.decimalPad)
                    Text("mg")
                        .padding()
                        .background(Color.secondarySystemBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }.padding()
                Button(
                    action: {
                        saveMeds(medName: medName, medAmount: medAmount)
                    }, label: {
                        Label("Add medication", systemImage: "plus")
                    }
                )
                .padding()
                .background(Color.accentColor)
                .foregroundColor(Color.primary)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            }.navigationTitle("Add medication")
        }
    }
}

struct AddMedsSheetView_Previews: PreviewProvider {
    static var previews: some View {
        AddMedsSheetView()
    }
}
