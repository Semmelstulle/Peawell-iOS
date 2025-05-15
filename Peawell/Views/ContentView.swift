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
                    Text("Peawell")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "plus")
                    Text(NSLocalizedString("tabbar.addMood", comment: "tells the user what the tab does"))
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text(NSLocalizedString("module.settings", comment: "should just say settings to tell the user where it navigates to"))
                }
        }
    }
}

#Preview {
    ContentView()
}
