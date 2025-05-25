//
//  CalendarView.swift
//  Peawell
//
//  Created by Dennis on 14.05.25.
//

import SwiftUI

struct CalendarView: View {
    @State private var progressValues: [CGFloat] = Array(repeating: 0, count: 7)
    
    var body: some View {
        GroupBox {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { index in
                        let isCurrentDay = index == 6
                        DayView(
                            progress: progressValues[index],
                            isCurrentDay: isCurrentDay,
                            dayOffset: index - 6,
                            containerWidth: geometry.size.width / 7
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, idealHeight: 120)
            .onAppear {
                progressValues = (0..<7).map { _ in CGFloat.random(in: 0...1) }
            }
        }
        .frame(height: 110)
    }
}

private struct DayView: View {
    let progress: CGFloat
    let isCurrentDay: Bool
    let dayOffset: Int
    let containerWidth: CGFloat
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                // Progress ring background
                Circle()
                    .stroke(lineWidth: 4)
                    .foregroundColor(.gray.opacity(0.2))
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        style: StrokeStyle(
                            lineWidth: 8,
                            lineCap: .round
                        )
                    )
                    .foregroundColor(.accentColor)
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: containerWidth * 0.6)
            .padding(.top, 4)
            
            // Day number
            Text(dayString)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isCurrentDay ? .white : .primary)
        }
        .frame(width: containerWidth)
        .padding(.vertical, 8)
        .background(isCurrentDay ? currentDayPill : nil)
    }
    
    private var dayString: String {
        let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date()) ?? Date()
        return Calendar.current.component(.day, from: date).description
    }
    
    private var currentDayPill: some View {
        Capsule()
            .fill(Color.accentColor)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
    }
}

#Preview {
    CalendarView()
}
