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
            OverView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text(overviewTitle)
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
