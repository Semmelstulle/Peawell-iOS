//
//  CalendarView.swift
//  Peawell
//
//  Created by Dennis on 14.05.25.
//

import SwiftUI

struct CalendarView: View {
    @State private var path = NavigationPath()
    @State private var scrollOffset: CGFloat = 0
    @State private var scrollProxy: ScrollViewProxy?
    private let totalDays = 105
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                GeometryReader { geometry in
                    let dayWidth = geometry.size.width / 7
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 0) {
                                ForEach(-90..<15, id: \.self) { offset in
                                    NavigationLink(value: dateForOffset(offset)) {
                                        DayView(
                                            dayOffset: offset,
                                            containerWidth: dayWidth,
                                            isCurrentDay: offset == 0
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .id(offset)
                                }
                            }
                            .background(GeometryReader { geo in
                                Color.clear.preference(
                                    key: ScrollOffsetKey.self,
                                    value: geo.frame(in: .named("scroll")).origin
                                )
                            })
                        }
                        .coordinateSpace(name: "scroll")
                        .onPreferenceChange(ScrollOffsetKey.self) { value in
                            scrollOffset = -value.x
                        }
                        .gesture(
                            DragGesture()
                                .onEnded { _ in
                                    let visibleDays = Int(round(scrollOffset / dayWidth))
                                    let snappedOffset = visibleDays - (visibleDays % 7)
                                    let targetOffset = max(min(snappedOffset, 104 * 7), 0)
                                    
                                    withAnimation(.spring()) {
                                        proxy.scrollTo(targetOffset, anchor: .center)
                                    }
                                }
                        )
                        .onAppear {
                            scrollProxy = proxy
                            proxy.scrollTo(0, anchor: .center)
                        }
                    }
                }
                .frame(height: 120)
            }
            .padding(.horizontal, -16)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("button.scrollToToday") {
                        withAnimation {
                            scrollProxy?.scrollTo(0, anchor: .center)
                        }
                    }
                }
            }
            .navigationDestination(for: Date.self) { date in
                DayDetailView(date: date)
            }
        }
    }
    
    private func dateForOffset(_ offset: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: offset, to: Date()) ?? Date()
    }
}
    
// MARK: - Helper Components

private struct DayView: View {
    let dayOffset: Int
    let containerWidth: CGFloat
    let isCurrentDay: Bool
    
    private var date: Date {
        Calendar.current.date(byAdding: .day, value: dayOffset, to: Date()) ?? Date()
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(lineWidth: 4)
                    .foregroundColor(.gray.opacity(0.2))
                Circle()
                    .trim(from: 0, to: 0.8)
                    .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .foregroundColor(isCurrentDay ? .white : .accentColor) // White for current day
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: containerWidth * 0.55)
            
            VStack(spacing: 2) {
                Text(dayString)
                    .font(.system(.callout, weight: .medium))
                Text(monthAbbreviation)
                    .font(.system(.footnote, weight: .light))
            }
            .foregroundColor(isCurrentDay ? .white : .primary)
        }
        .frame(width: containerWidth)
        .padding(.vertical, 8)
        .background(isCurrentDay ? currentDayPill : nil)
    }
    
    private var dayString: String {
        Calendar.current.component(.day, from: date).description
    }
    
    private var monthAbbreviation: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
    
    private var currentDayPill: some View {
        Capsule()
            .fill(Color.accentColor)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
    }
}

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}

struct DayDetailView: View {
    let date: Date
    var body: some View {
        Text("Details for \(date.formatted(date: .long, time: .omitted))")
            .navigationTitle(date.formatted(date: .abbreviated, time: .omitted))
    }
}

#Preview {
    CalendarView()
}

#Preview {
    MainView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
