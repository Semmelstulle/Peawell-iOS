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

    //  adds relevant UserDefaults to scope
    @AppStorage("settingShowMoodSection") private var settingShowMoodSection = true
    @AppStorage("settingShowMedicationSection") private var settingShowMedicationSection = true
    
    var body: some View {
        NavigationView {
            Form {
                //  section for mood
                if settingShowMoodSection == true {
                    Section(header: Text("Mood")) {
                        TextField(text: $actName, prompt: Text("What did you do today?")) {Text("Activity name")}
                        TextField(text: $moodName, prompt: Text("How did you feel today?")) {Text("Your mood")}
                        Button(action: {
                            saveMood(actName: actName, moodName: moodName)
                        }, label: {
                            Label("Add activity", systemImage: "plus")
                        })
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
