//
//  AddActivityView.swift
//  Peawell
//
//  Created by Dennis on 12.04.23.
//

import SwiftUI

struct AddActivityView: View {
    
    //  these define the user input field's empty state
    @State private var medName: String = ""
    @State private var medAmount: String = ""
    @State private var actName: String = ""
    @State private var moodName: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                //  section for meds
                Section(header: Text("Medication")) {
                    TextField(text: $medName, prompt: Text("Name of medication goes here")) {Text("Medication name")}
                    TextField(text: $medAmount, prompt: Text("Dose needed in mg goes here")) {Text("Medicaton dose")}
                    Button(action: {
                        // function here
                    }, label: {
                        Label("Add medication", systemImage: "plus")
                    })
                    
                }
                //  section for mood
                Section(header: Text("Mood")) {
                    TextField(text: $actName, prompt: Text("What did you do today?")) {Text("Activity name")}
                    TextField(text: $moodName, prompt: Text("How did you feel today?")) {Text("Your mood")}
                    Button(action: {
                        // function here
                    }, label: {
                        Label("Add activity", systemImage: "plus")
                    })
                }
                //sets the title for the NavView
            }.navigationTitle(addTitle)
        }
    }
}

struct AddActivityView_Previews: PreviewProvider {
    static var previews: some View {
        AddActivityView()
    }
}
