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

    @AppStorage("settingShowMoodSection") private var settingShowMoodSection = true
    @AppStorage("settingShowMedicationSection") private var settingShowMedicationSection = true
        
    var body: some View {
        NavigationView {
            VStack() {
                if settingShowMoodSection == true {
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
                    }
                };
                //  checks UserDefaults if section is active
                if settingShowMedicationSection == true {
                    Form() {
                        VStack() {
                            HStack() {
                                Rectangle()
                                Rectangle()
                            }
                            HStack() {
                                Rectangle()
                                Rectangle()
                            }
                        }.frame(height: 200)
                        Label("Test", systemImage: "homekit")
                        Label("Test", systemImage: "homekit")
                        Label("Test", systemImage: "homekit")
                        Label("Test", systemImage: "homekit")
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
