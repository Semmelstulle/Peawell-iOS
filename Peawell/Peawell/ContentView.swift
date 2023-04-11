//
//  ContentView.swift
//  Peawell
//
//  Created by Dennis on 11.04.23.
//

import SwiftUI

//  Constants stored on the top
let mainTitle: String = "Peawell"
let histTitle: String = "History"
let settingsTitle: String = "Settings"


struct ContentView: View {
    var body: some View {
        TabView {
            MainView()
                .navigationBarTitle("Test", displayMode: .inline)
                .tabItem {
                    Image(systemName: "iphone.homebutton")
                    Text(mainTitle)
                }
            HistoryView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text(histTitle)
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text(settingsTitle)
                }
        }
        .padding()
        
    }

    struct MainView: View {
        var body: some View {
            VStack(
                spacing: 20
            ) {
                Text("henlo");
                HStack(
                    spacing: 30
                ) {
                    RoundedRectangle(
                        cornerRadius: 30,
                        style: .continuous
                    )
                        .foregroundColor(.accentColor)
                        .frame(width: 200, height: 200)
                    RoundedRectangle(
                        cornerRadius: 30,
                        style: .continuous
                    )
                        .foregroundColor(.accentColor)
                        .frame(width: 200, height: 200)
                }
                
                
                    
            }
            
        }
    }
    struct HistoryView: View {
        var body: some View {
            Color.gray
        }
    }
    struct SettingsView: View {
        var body: some View {
            Color.blue
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
