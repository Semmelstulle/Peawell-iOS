//
//  MainView.swift
//  Peawell
//
//  Created by Dennis on 12.04.23.
//

import SwiftUI

//  constants stored on top
let dayButtonSize: CGFloat = 40

struct MainView: View {
    
    @AppStorage("settingShowMedicationSection") private var settingShowMedicationSection = true
    
    @State var current_date = Date()
    
    var body: some View {
        NavigationView {
            VStack() {
                VStack() {
                    HStack(spacing: 10) {
                        ForEach(0..<7) { index in
                            DayButtonView(label: "\(index+1)")
                        }
                    }
                    HStack(spacing: 10) {
                        ForEach(0..<7) { index in
                            DayButtonView(label: "\(index+8)")
                        }
                    }
                };
                //  checks UserDefaults if section is active
                if settingShowMedicationSection == true {
                    ZStack() {
                        Circle().foregroundColor(.secondary)
                        Text("Spooky")
                    }
                }
            }
            .navigationTitle(mainTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
    
    //  prepares the day cell
    struct DayButtonView: View {
        @State var label: String
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundColor(.accentColor).frame(width: (dayButtonSize), height: (dayButtonSize));
                Text(label)
            }
        }
    }
    
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
