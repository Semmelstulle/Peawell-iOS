//
//  MainView.swift
//  Peawell
//
//  Created by Dennis on 12.04.23.
//

import SwiftUI

struct MainView: View {
    
    //  adds UserDefaults to scope
    @AppStorage("settingShowMoodSection") private var settingShowMoodSection = true
    @AppStorage("settingShowMedicationSection") private var settingShowMedicationSection = true
    
    var body: some View {
        NavigationView {
            ScrollView() {
                ZStack() {
                    Text("Motivational quote needed here. Maybe there's a public api?\nPlus this needs a fixed height at some point.")
                        .padding()
                        .foregroundColor(Color.secondarySystemBackground)
                        .background(LinearGradient(gradient: Gradient(colors: [.green, .mint]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .clipShape(
                            RoundedRectangle(cornerRadius: 15)
                        )
                        .aspectRatio(2.2, contentMode: .fit)
                        .padding()
                }
                // the next sections are toggled by UserDefaults
                if settingShowMoodSection == true {
                    MoodPickerView()
                        .padding()
                }
                if settingShowMedicationSection == true {
                    MedsView()
                        .padding()
                }
                if settingShowMedicationSection == false && settingShowMoodSection == false {
                    Text("All modules disabled")
                        .padding()
                }
            }
            .navigationTitle("Peawell")
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
