//
//  ContentView.swift
//  Peawell
//
//  Created by Dennis on 11.04.23.
//

import SwiftUI

//  constants stored on the top
let mainTitle: String = "Peawell"
let addTitle: String = "Add entry"
let settingsTitle: String = "Settings"


struct ContentView: View {
    
    
    
    var body: some View {
        TabView {
            MainView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Peawell")
                }
                .navigationBarTitle(mainTitle)
            AddActivityView()
                .tabItem {
                    Image(systemName: "plus.rectangle.fill")
                    Text("Add activity")
                }
                .navigationBarTitle(addTitle)
                .tag(1)
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .navigationBarTitle(settingsTitle)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
