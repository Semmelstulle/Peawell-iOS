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

    @State var showSettingsSheet = false
    
    //  gets current date and formats it so it can be used as the
    //  navigationTitle for the view
    var navTitleDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d. MMM."
        return formatter.string(from: Date())
    }

    var body: some View {
        NavigationView {
            ScrollView() {
                
                CalendarProgressView()
                    .frame(height: 80)
                    .padding(.horizontal)

                //  the next sections are toggled by UserDefaults
                if settingShowMoodSection == true {
                    MoodPickerView()
                        .padding()
                }
                if settingShowMedicationSection == true {
                    MedsView()
                        .padding()
                }
                if settingShowMedicationSection == false && settingShowMoodSection == false {
                    Text(NSLocalizedString("main.empty.hint", comment: "tell the person that all modules are disabled thus there is nothing here."))
                        .padding()
                }

                //  here the user gets to see all saved entries
                VStack {
                    NavigationLink(destination: MoodLogView()) {
                        Image("moodAwesome")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(6)
                            .background(Color.mint)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            //  padding options below try to mimic a native list view placement
                            .padding(.top, 6)
                            .padding(.bottom, 6)
                            .padding(.leading, 16)
                            .padding(.trailing, 6)
                        Text(NSLocalizedString("module.moods", comment: "just says mood diary"))
                            .foregroundStyle(Color.primary)
                        Spacer()
                        Image(systemName: "chevron.forward")
                            .padding(.trailing, 10)
                            .foregroundStyle(Color.primary)
                            .opacity(0.4)
                    }
                    .background(Color.secondarySystemBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    NavigationLink(destination: MedLogView()) {
                        Image("Long pill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(6)
                            .background(Color.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            //  padding options below try to mimic a native list view placement
                            .padding(.top, 6)
                            .padding(.bottom, 6)
                            .padding(.leading, 16)
                            .padding(.trailing, 6)
                        Text(NSLocalizedString("module.med", comment: "just says medication log"))
                            .foregroundStyle(Color.primary)
                        Spacer()
                        Image(systemName: "chevron.forward")
                            .padding(.trailing, 10)
                            .foregroundStyle(Color.primary)
                            .opacity(0.4)
                    }
                    .background(Color.secondarySystemBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding()
            }
            .navigationTitle(navTitleDate)
            //  is needed so the text is not centered in view
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .sheet(isPresented: $showSettingsSheet) {
            //  check here is needed, because iOS 15 sheets can only be full screen
            if #available(iOS 16.0, *) {
                SettingsView()
                    .presentationDetents([.large])
            } else {
                SettingsView()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
