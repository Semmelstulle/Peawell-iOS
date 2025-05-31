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
        VStack(spacing: 0) {
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
            .frame(height: 80)
        }
        .padding(.horizontal, -16)
        .toolbar {
            ToolbarItem {
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
        VStack(spacing: 6) {
            Text(dayOfWeekLetter)
                .font(.title3)
                .foregroundColor(.secondary)
                .frame(height: 24)
            if isCurrentDay {
                ZStack {
                    Circle()
                        .fill(Color.accentColor)
                    Text(dayString)
                        .font(.title3)
                        .foregroundColor(.white)
                }
                .frame(width: containerWidth * 0.75, height: containerWidth * 0.75)
            } else {
                Text(dayString)
                    .font(.title3)
                    .foregroundColor(.primary)
                    .frame(width: containerWidth * 0.75, height: containerWidth * 0.75)
            }
        }
        .frame(width: containerWidth)
        .padding(.vertical, 8)
    }
    
    private var dayString: String {
        Calendar.current.component(.day, from: date).description
    }
    
    private var dayOfWeekLetter: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "EEEEE"
        return formatter.string(from: date)
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
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \LogTimeMeds.logTimes, ascending: false)], animation: .default)
    var medLogs: FetchedResults<LogTimeMeds>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Mood.logDate, ascending: false)], animation: .default)
    var moodLogs: FetchedResults<Mood>
    
    var body: some View {
        List {
            Section(header: Text("section.header.medHistory")) {
                ForEach(medLogsForDay, id: \.self) { item in
                    HStack {
                        Image(item.medication?.medKind ?? "longPill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(6)
                            .background(Color.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        Text(item.medication?.medType ?? "Unknown Medication")
                        Spacer()
                        if let logTime = item.logTimes {
                            Text(logTime.formatted(date: .abbreviated, time: .shortened))
                                .opacity(0.4)
                        }
                    }
                }
            }
            Section(header: Text("title.diary")) {
                ForEach(moodLogsForDay, id: \.self) { item in
                    NavigationLink(destination: MoodDetailSubView(item: item)) {
                        HStack {
                            Image("mood\(item.moodName ?? "Neutral")")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(6)
                                .background(getMoodColor(item.moodName))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            Text(item.logDate ?? Date.now, style: .date)
                        }
                    }
                }
            }
        }
        .navigationTitle(date.formatted(date: .abbreviated, time: .omitted))
    }
    
    private var medLogsForDay: [LogTimeMeds] {
        medLogs.filter { log in
            guard let logDate = log.logTimes else { return false }
            return Calendar.current.isDate(logDate, inSameDayAs: date)
        }
    }
    private var moodLogsForDay: [Mood] {
        moodLogs.filter { log in
            guard let logDate = log.logDate else { return false }
            return Calendar.current.isDate(logDate, inSameDayAs: date)
        }
    }
}

private struct MoodDetailSubView: View {
    let item: Mood
    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    Image("mood\(item.moodName ?? "Neutral")")
                    Spacer()
                }
            }
            .listRowBackground(getMoodColor(item.moodName))
            Section {
                Text(item.activityName ?? "Text missing")
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .navigationTitle(Text(item.logDate ?? Date.now, style: .date))
    }
}

#Preview {
    CalendarView()
}

#Preview {
    MainView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
