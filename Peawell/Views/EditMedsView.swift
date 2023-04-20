//
//  EditMedsView.swift
//  Peawell
//
//  Created by Dennis on 19.04.23.
//

import SwiftUI

struct EditMedsView: View { var navTitle: String

    //  these define the user input field's empty state
    @State var medName: String = ""
    @State var medAmount: String = ""
    @State var medUnit: String = ""

    var body: some View {
        NavigationView() {
            Form() {
                TextField(
                    text: $medName,
                    prompt: Text("What is your medication called?")
                ) {
                    Text("Activity name")
                }
                .padding()
                TextField(
                    text: $medAmount,
                    prompt: Text("Dose here")
                ) {
                    Text("Your mood")
                }
                .padding()
                Button(
                    action: {
                        saveMeds(medName: medName, medAmount: medAmount, medUnit: medUnit)
                    }, label: {
                        Label("Add medication", systemImage: "plus")
                    }
                )
            }.navigationTitle(navTitle)
        }
    }
}

struct EditMedsView_Previews: PreviewProvider {
    static var previews: some View {
        EditMedsView(navTitle: "Test")
    }
}
