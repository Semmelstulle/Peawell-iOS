//
//  WeekdayPicker.swift
//  Peawell
//
//  Created by Dennis on 27.07.25.
//

import SwiftUI

struct WeekdayPicker: View {
    @Binding var selectedDays: Set<Int>

    private var days: [String] {
        let symbols = Calendar.current.veryShortStandaloneWeekdaySymbols
        guard symbols.count == 7 else { return ["M","T","W","T","F","S","S"] }
        return Array(symbols[1...6]) + [symbols[0]]
    }

    var body: some View {
        GeometryReader { geometry in
            let totalSpacing: CGFloat = 12 * 6
            let maxWidth = geometry.size.width
            // Calculate buttonDiameter to fit within width with spacing
            let buttonDiameter = min(40, (maxWidth - totalSpacing) / 7)

            HStack(spacing: 12) {
                ForEach(0..<7, id: \.self) { dayIndex in
                    Button(action: {
                        toggle(day: dayIndex)
                    }) {
                        Text(days[dayIndex])
                            .font(.headline)
                            .foregroundColor(selectedDays.contains(dayIndex) ? .white : .primary)
                            .frame(width: buttonDiameter, height: buttonDiameter)
                            .background(
                                Circle()
                                    .fill(selectedDays.contains(dayIndex) ? Color.accentColor : Color.clear)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel(Text("Toggle \(days[dayIndex])"))
                }
            }
            .frame(height: buttonDiameter)
            .frame(maxWidth: .infinity)
        }
        .frame(height: 38) // Fixed height for GeometryReader container
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
