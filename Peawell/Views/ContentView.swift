//
//  TabView.swift
//  Peawell
//
//  Created by Dennis on 14.05.25.
//

import SwiftUI

struct ContentView: View {
    @State private var showAddSheet = false
    @State private var isBouncing = false
    
    
    var body: some View {
        ZStack {
            TabView() {
                MainView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Peawell")
                    }
                
                // placeholder for spacing, will be overlapped by custom plus button
                HStack {}
                
                SettingsView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text(NSLocalizedString("module.settings", comment: "Settings"))
                    }
            }
            
            // custom plus button overlay
            Button(action: {
                showAddSheet = true
            }) {
                Image(systemName: "plus.rectangle.fill")
                    .resizable()
                // needed to keep the aspect ratio of the sfsymbol when setting custom height
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40)
                    .scaleEffect(1.1)
                // use gradient for older iOS/SwiftUI, color mixing for newer SwiftUI
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.accentColor, .mint],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .offset(y: 5)
                    .padding([.top, .bottom], 15)
                    .padding([.leading, .trailing], 50)
            }
            .frame(maxWidth: .infinity)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            
        }
        .sheet(isPresented: $showAddSheet) {
            if #available(iOS 16.0, *) {
                AddMedsSheetView()
                    .presentationDetents([.medium, .large])
            } else {
                AddMedsSheetView()
            }
        }
    }
}


#Preview {
    ContentView()
}
