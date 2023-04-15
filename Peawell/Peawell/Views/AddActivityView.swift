//
//  AddActivityView.swift
//  Peawell
//
//  Created by Dennis on 12.04.23.
//

import SwiftUI

struct AddActivityView: View {
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Mood.moodName, ascending: true)], animation: .default)
    var items: FetchedResults<Mood>
    
    //  these define the user input field's empty state
    @State var medName: String = ""
    @State var medAmount: String = ""
    @State var actName: String = ""
    @State var moodName: String = ""
    
    @AppStorage("settingShowMoodSection") private var settingShowMoodSection = true
    @AppStorage("settingShowMedicationSection") private var settingShowMedicationSection = true
    
    var body: some View {
        NavigationView {
            Form {
                //  section for meds
                if settingShowMedicationSection == true {
                    Section(header: Text("Medication")) {
                        TextField(text: $medName, prompt: Text("Name of medication goes here")) {Text("Medication name")}
                        TextField(text: $medAmount, prompt: Text("Dose needed in mg goes here")) {Text("Medicaton dose")}
                            .keyboardType(.decimalPad)
                        Button(action: {
                            saveMeds()
                            /* needs function to
                             - check for both fields being filled
                             - clear the textField
                             */
                        }, label: {
                            Label("Add medication", systemImage: "plus")
                        })
                    }
                }
                //  section for mood
                if settingShowMoodSection == true {
                    Section(header: Text("Mood")) {
                        TextField(text: $actName, prompt: Text("What did you do today?")) {Text("Activity name")}
                        TextField(text: $moodName, prompt: Text("How did you feel today?")) {Text("Your mood")}
                        Button(action: {
                            saveMood()
                            /* needs function to
                             - check for both fields being filled
                             - clear the textField
                             */
                        }, label: {
                            Label("Add activity", systemImage: "plus")
                        }
                        )
                    }
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
