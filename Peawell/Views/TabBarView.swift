//
//  TabBarView.swift
//  Peawell
//
//  Created by Dennis on 19.04.23.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
        
        //  this is literally just the tabs on the bottom
        TabView() {
            MainView()
                .tabItem {
                    Image("peaGlyph")
                        .renderingMode(.template)
                        .foregroundColor(.white)
                    Text("Startseite")
                }
            OverView()
                .tabItem {
                    Image("overviewGlyph")
                        .renderingMode(.template)
                        .foregroundColor(.white)
                    Text("Overview")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
