//
//  CalendarView.swift
//  Peawell
//
//  Created by Dennis on 18.04.23.
//

import SwiftUI

struct CalendarView: View {
    var body: some View {
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
    }
}

//  prepares the day cell
struct DayButtonView: View {
    @State var label: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous).foregroundColor(.accentColor).aspectRatio(1, contentMode: .fit);
            Text(label)
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
