//
//  TabBarView.swift
//  Peawell
//
//  Created by Dennis on 19.04.23.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView() {
            MainView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text(mainTitle)
                }
            AddActivityView()
                .tabItem {
                    Image(systemName: "plus")
                    Text(addTitle)
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text(settingsTitle)
                }
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
