//
//  DayPicker.swift
//  Peawell
//
//  Created by Dennis on 27.07.25.
//

import SwiftUI

struct WeekdayPicker: View {
    @Binding var selectedDays: Set<Int> // 0 = Monday, 6 = Sunday

    private var days: [String] {
        let symbols = Calendar.current.veryShortStandaloneWeekdaySymbols
        let sundayFirst = symbols
        guard sundayFirst.count == 7 else { return ["M","T","W","T","F","S","S"] }
        return Array(sundayFirst[1...6]) + [sundayFirst[0]]
    }

    var body: some View {
        GeometryReader { geometry in
            let totalSpacing: CGFloat = 12 * 6 // 6 gaps between 7 buttons
            let buttonWidth = (geometry.size.width - totalSpacing) / 7

            HStack(spacing: 12) {
                ForEach(0..<7, id: \.self) { dayIndex in
                    Button(action: {
                        toggle(day: dayIndex)
                        //print("Toggled day \(dayIndex), now selectedDays: \(selectedDays.sorted())")
                    }) {
                        Text(days[dayIndex])
                            .font(.headline)
                            .frame(width: buttonWidth, height: buttonWidth)
                            .background(
                                Circle()
                                    .fill(selectedDays.contains(dayIndex) ? Color.accentColor : Color.clear)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel(Text("Toggle \(days[dayIndex])"))
                }
            }
            // Fix vertical size of the GeometryReader as well so it doesn't expand vertically
            .frame(height: buttonWidth)
        }
        // Make sure the picker expands horizontally as much as it can in parent
        .frame(minHeight: 34)
    }

    private func toggle(day: Int) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }
}


struct WeekdayPicker_Previews: PreviewProvider {
    @State static var days: Set<Int> = []

    static var previews: some View {
        WeekdayPicker(selectedDays: $days)
    }
}
