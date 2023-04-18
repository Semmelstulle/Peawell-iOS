//
//  MedDetailsView.swift
//  Peawell
//
//  Created by Dennis on 17.04.23.
//

import SwiftUI

struct MedDetailsView: View { var detailTitle: Text

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Mood.moodName, ascending: true)], animation: .default)
    var items: FetchedResults<Mood>

    //  these define the user input field's empty state
    @State var medName: String = ""
    @State var medAmount: String = ""
    @State var actName: String = ""
    @State var moodName: String = ""

    var body: some View {
        Form() {
            detailTitle
                .font(.title)
                .listRowBackground(Color.clear)
            Section() {
                TextField(text: $medName, prompt: Text("Name of medication goes here")) {Text("Medication name")}
                TextField(text: $medAmount, prompt: Text("Dose needed in mg goes here")) {Text("Medicaton dose")}
                    .keyboardType(.decimalPad)
                Button(action: {
                    saveMeds(medName: medName, medAmount: medAmount)
                }, label: {
                    Label("Add medication", systemImage: "plus")
                })

            }
        }
    }
}

struct MedDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
