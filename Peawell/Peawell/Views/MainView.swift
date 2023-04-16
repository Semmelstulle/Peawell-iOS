//
//  MainView.swift
//  Peawell
//
//  Created by Dennis on 12.04.23.
//

import SwiftUI

//  constants stored on top

struct MainView: View {

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Mood.moodName, ascending: true)], animation: .default)
    var moodItems: FetchedResults<Mood>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Meds.medType, ascending: true)], animation: .default)
    var medsItems: FetchedResults<Meds>
    @AppStorage("settingShowMoodSection") private var settingShowMoodSection = true
    @AppStorage("settingShowMedicationSection") private var settingShowMedicationSection = true
    
    var body: some View {
        NavigationView {
            Form() {
                // checks UserDefaults if section is active
                if settingShowMoodSection == true {
                    Section(header: Text("Mood")) {
                        VStack() {
                            HStack(spacing: 10) {
                                ForEach(0..<7) { index in
                                    DayButtonView(label: "\(index+1)")
                                }
                            }
                            HStack(spacing: 10) {
                                ForEach(0..<7) { index in
                                    DayButtonView(label: "\(index+8)")
                                }
                            }
                        }
                    }
                }
                //  checks UserDefaults if section is active
                if settingShowMedicationSection == true {
                    Section(header: Text("Medication")) {
                        VStack() {
                            HStack() {
                                Rectangle()
                                Rectangle()
                            }
                            HStack() {
                                Rectangle()
                                Rectangle()
                            }
                        }.frame(height: 200)
                        
                    }
                }
                Section(header: Text("Meds log")) {
                    ForEach(medsItems) { item in
                        HStack() {
                            Text(item.medType ?? "Error")
                            Text(item.medDose ?? "Error")
                        }
                    }
                }
                Section(header: Text("Mood log")) {
                    ForEach(moodItems) { item in
                        HStack() {
                            Text(item.activityName ?? "Error")
                            Text(item.moodName ?? "Error")
                        }
                    }
                }
            }
            .navigationTitle(mainTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
    
    //  prepares the day cell
    struct DayButtonView: View {
        @State var label: String
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous).foregroundColor(.accentColor).aspectRatio(1, contentMode: .fit);
                Text(label)
            }
        }
    }

    // prepares the med cell
    struct MedButtonView: View {
        @State var label: String
        var body: some View {
            ZStack() {
                
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
