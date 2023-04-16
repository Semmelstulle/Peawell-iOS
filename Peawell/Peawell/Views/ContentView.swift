//
//  ContentView.swift
//  Peawell
//
//  Created by Dennis on 11.04.23.
//

import SwiftUI

// this is just the navigation bar, not much here besides the three items in it

struct ContentView: View {
    
    var body: some View {
        TabView {
            MainView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text(mainTitle)
                }
                .navigationBarTitle(mainTitle)
            AddActivityView()
                .tabItem {
                    Image(systemName: "plus.rectangle")
                    Text(addTitle)
                }
                .navigationBarTitle(addTitle)
                .tag(1)
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text(settingsTitle)
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
