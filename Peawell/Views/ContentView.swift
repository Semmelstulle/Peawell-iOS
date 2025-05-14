//
//  TabView.swift
//  Peawell
//
//  Created by Dennis on 14.05.25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MainView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            AddMedsSheetView()
                .tabItem {
                    Image(systemName: "plus")
                    Text("Log now")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
