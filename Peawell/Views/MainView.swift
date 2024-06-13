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
                    RoundedRectangle(cornerRadius: 15)
                        .fill(LinearGradient(gradient: Gradient(colors: [.green, .mint]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .aspectRatio(2.2, contentMode: .fit)
                    Text(NSLocalizedString("motivational quote", comment: "a quote to motivate the person"))
                        .foregroundColor(Color.secondarySystemBackground)
                        .aspectRatio(2.2, contentMode: .fill)
                        .padding()
                }
                .padding()
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
                    Text(NSLocalizedString("empty view", comment: "tell the person that all modules are disabled thus there is nothing here."))
                        .padding()
                }
            }
            .navigationTitle("Peawell")
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .toolbar {
                ToolbarItem {
                    Menu {
                        Toggle(isOn: $settingShowMedicationSection, label: {Text("Use medication module")})
                        Toggle(isOn: $settingShowMoodSection, label: {Text("Use mood module")})
                    } label: {
                        Label("Menu", systemImage: "ellipsis.circle")
                    }
                }

            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
