//
//  Pickers.swift
//  Peawell
//
//  Created by Dennis on 27.07.25.
//

import SwiftUI

struct WeekdayPicker: View {
    @Binding var selectedDays: Set<Int> // Days 1 through 7 (Sunday = 1 ... Saturday = 7)
    
    private var firstWeekday: Int {
        Calendar.current.firstWeekday // E.g., Sunday = 1 for en_US, Monday = 2 for en_DE
    }
    
    private var orderedWeekdayIndices: [Int] {
        let weekdays = Array(1...7)
        let index = firstWeekday - 1
        return Array(weekdays[index...]) + Array(weekdays[..<index])
    }
    
    private var weekdaySymbols: [String] {
        let rawSymbols = Calendar.current.veryShortStandaloneWeekdaySymbols
        guard rawSymbols.count == 7 else { return ["S", "M", "T", "W", "T", "F", "S"] }
        // Rotate symbols based on firstWeekday
        let index = firstWeekday - 1
        return Array(rawSymbols[index...]) + Array(rawSymbols[..<index])
    }
    
    var body: some View {
        GeometryReader { geometry in
            let totalSpacing: CGFloat = 12 * 6
            let maxWidth = geometry.size.width
            let buttonDiameter = min(40, (maxWidth - totalSpacing) / 7)
            
            HStack(spacing: 12) {
                ForEach(orderedWeekdayIndices.indices, id: \.self) { i in
                    let day = orderedWeekdayIndices[i]
                    
                    Button(action: {
                        toggle(day: day)
                    }) {
                        Text(weekdaySymbols[i])
                            .font(.headline)
                            .foregroundColor(selectedDays.contains(day) ? .white : .primary)
                            .frame(width: buttonDiameter, height: buttonDiameter)
                            .background(
                                Circle()
                                    .fill(selectedDays.contains(day) ? Color.accentColor : Color.clear)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel(Text("Toggle \(weekdaySymbols[i])"))
                }
            }
            .frame(height: buttonDiameter)
            .frame(maxWidth: .infinity)
        }
        .frame(height: 38)
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
    @State static var selected: Set<Int> = [2, 4]
    
    static var previews: some View {
        WeekdayPicker(selectedDays: $selected)
            .frame(width: 350)
    }
}

struct TimePicker: View {
    @Binding var times: [Date]
    let isUsedToEdit: Bool
    
    var body: some View {
        ForEach(times.indices, id: \.self) { index in
            HStack {
                DatePicker("", selection: Binding(
                    get: { times[index] },
                    set: { times[index] = $0; sortTimes() }
                ), displayedComponents: [.hourAndMinute])
                .labelsHidden()
                .disabled(!isUsedToEdit)
                Spacer()
                if times.count > 1 && isUsedToEdit {
                    Button(role: .destructive) {
                        withAnimation {
                            times.remove(at: index)
                            sortTimes()
                        }
                    } label: {
                        Image(systemName: "minus.circle")
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
        if isUsedToEdit {
            Button {
                withAnimation {
                    addNextHour()
                }
            } label: {
                Label("label.addTime", systemImage: "plus.circle")
            }
        }
    }
    
    private func addNextHour() {
        var nextTime: Date
        let calendar = Calendar.current
        if times.isEmpty {
            let now = Date()
            nextTime = calendar.nextDate(after: now, matching: DateComponents(minute: 0), matchingPolicy: .nextTime)!
        } else {
            let sorted = times.sorted()
            nextTime = sorted.last!
            repeat {
                nextTime = calendar.date(byAdding: .hour, value: 1, to: nextTime)!
            } while times.contains(where: { calendar.component(.hour, from: $0) == calendar.component(.hour, from: nextTime) && calendar.component(.minute, from: $0) == 0 })
        }
        nextTime = calendar.date(bySetting: .minute, value: 0, of: nextTime)!
        times.append(nextTime)
        sortTimes()
    }
    
    private func sortTimes() {
        times.sort { $0.compare($1) == .orderedAscending }
    }
}
