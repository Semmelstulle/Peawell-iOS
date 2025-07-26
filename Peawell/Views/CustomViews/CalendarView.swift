//
//  CalendarView.swift
//  Peawell
//
//  Created by Dennis on 14.05.25.
//

import SwiftUI

// MARK: - Configuration

struct CalendarConfiguration {
    let daysRange: Range<Int>
    let calendarHeight: CGFloat
    let snapToWeeks: Bool
    let showCurrentDayIndicator: Bool
    let currentDayAccentColor: Color
    let daySpacing: CGFloat
    
    static let `default` = CalendarConfiguration(
        daysRange: -28..<7,
        calendarHeight: 80,
        snapToWeeks: true,
        showCurrentDayIndicator: true,
        currentDayAccentColor: .accentColor,
        daySpacing: 0
    )
}

// MARK: - Main Calendar View

struct CalendarView: View {
    @StateObject private var scrollController = CalendarScrollController()
    @State private var currentDate = Date()
    
    let configuration: CalendarConfiguration
    
    init(configuration: CalendarConfiguration = .default) {
        self.configuration = configuration
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HorizontalCalendarScrollView(
                configuration: configuration,
                currentDate: currentDate,
                scrollController: scrollController
            )
            .frame(height: configuration.calendarHeight)
        }
        .padding(.horizontal, -16)
        .toolbar {
            ToolbarItem {
                Button("button.scrollToToday") {
                    updateCurrentDate()
                    scrollController.scrollToCurrentDay(from: currentDate)
                }
            }
        }
        .navigationDestination(for: Date.self) { date in
            DayDetailView(date: date)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            updateCurrentDate()
        }
    }
    
    private func updateCurrentDate() {
        let newDate = Date()
        if !Calendar.current.isDate(currentDate, inSameDayAs: newDate) {
            currentDate = newDate
        }
    }
}

// MARK: - Scroll Controller

class CalendarScrollController: ObservableObject {
    private var scrollProxy: ScrollViewProxy?
    @Published private var scrollOffset: CGFloat = 0
    
    func setScrollProxy(_ proxy: ScrollViewProxy) {
        self.scrollProxy = proxy
    }
    
    func updateScrollOffset(_ offset: CGFloat) {
        self.scrollOffset = offset
    }
    
    func scrollToCurrentDay(from currentDate: Date) {
        let today = Date()
        let daysDifference = Calendar.current.dateComponents([.day], from: currentDate, to: today).day ?? 0
        
        withAnimation {
            scrollProxy?.scrollTo(daysDifference, anchor: .center)
        }
    }
    
    func handleSnapToWeek(dayWidth: CGFloat, configuration: CalendarConfiguration) {
        guard configuration.snapToWeeks else { return }
        
        let visibleDays = Int(round(scrollOffset / dayWidth))
        let snappedOffset = visibleDays - (visibleDays % 7)
        let maxOffset = (configuration.daysRange.upperBound - configuration.daysRange.lowerBound) * 7
        let targetOffset = max(min(snappedOffset, maxOffset), 0)
        
        withAnimation(.spring()) {
            scrollProxy?.scrollTo(targetOffset, anchor: .center)
        }
    }
}

// MARK: - Horizontal Calendar Scroll View

private struct HorizontalCalendarScrollView: View {
    let configuration: CalendarConfiguration
    let currentDate: Date
    let scrollController: CalendarScrollController
    
    var body: some View {
        GeometryReader { geometry in
            let dayWidth = geometry.size.width / 7
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    DayRowView(
                        configuration: configuration,
                        currentDate: currentDate,
                        dayWidth: dayWidth
                    )
                    .background(
                        ScrollOffsetReader { offset in
                            scrollController.updateScrollOffset(-offset.x)
                        }
                    )
                }
                .coordinateSpace(name: "scroll")
                .gesture(
                    DragGesture()
                        .onEnded { _ in
                            scrollController.handleSnapToWeek(
                                dayWidth: dayWidth,
                                configuration: configuration
                            )
                        }
                )
                .onAppear {
                    scrollController.setScrollProxy(proxy)
                    scrollController.scrollToCurrentDay(from: currentDate)
                }
            }
        }
    }
}

// MARK: - Day Row View

private struct DayRowView: View {
    let configuration: CalendarConfiguration
    let currentDate: Date
    let dayWidth: CGFloat
    
    var body: some View {
        LazyHStack(spacing: configuration.daySpacing) {
            ForEach(configuration.daysRange, id: \.self) { offset in
                NavigationLink(value: dateForOffset(offset)) {
                    DayView(
                        date: dateForOffset(offset),
                        containerWidth: dayWidth,
                        isCurrentDay: isCurrentDayForOffset(offset),
                        configuration: configuration
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .id(offset)
            }
        }
    }
    
    private func dateForOffset(_ offset: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: offset, to: currentDate) ?? currentDate
    }
    
    private func isCurrentDayForOffset(_ offset: Int) -> Bool {
        let today = Date()
        let offsetDate = dateForOffset(offset)
        return Calendar.current.isDate(offsetDate, inSameDayAs: today)
    }
}

// MARK: - Scroll Offset Reader

private struct ScrollOffsetReader: View {
    let onOffsetChange: (CGPoint) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            Color.clear.preference(
                key: ScrollOffsetKey.self,
                value: geometry.frame(in: .named("scroll")).origin
            )
        }
        .onPreferenceChange(ScrollOffsetKey.self, perform: onOffsetChange)
    }
}

// MARK: - Day View

private struct DayView: View {
    let date: Date
    let containerWidth: CGFloat
    let isCurrentDay: Bool
    let configuration: CalendarConfiguration
    
    var body: some View {
        VStack(spacing: 6) {
            DayOfWeekLabel(date: date)
            DayNumberView(
                date: date,
                containerWidth: containerWidth,
                isCurrentDay: isCurrentDay,
                configuration: configuration
            )
        }
        .frame(width: containerWidth)
        .padding(.vertical, 8)
    }
}

// MARK: - Day Components

private struct DayOfWeekLabel: View {
    let date: Date
    
    var body: some View {
        Text(dayOfWeekLetter)
            .font(.title3)
            .foregroundColor(.secondary)
            .frame(height: 24)
    }
    
    private var dayOfWeekLetter: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "EEEEE"
        return formatter.string(from: date)
    }
}

private struct DayNumberView: View {
    let date: Date
    let containerWidth: CGFloat
    let isCurrentDay: Bool
    let configuration: CalendarConfiguration
    
    var body: some View {
        Group {
            if isCurrentDay && configuration.showCurrentDayIndicator {
                CurrentDayIndicator(
                    dayString: dayString,
                    containerWidth: containerWidth,
                    accentColor: configuration.currentDayAccentColor
                )
            } else {
                RegularDayText(
                    dayString: dayString,
                    containerWidth: containerWidth
                )
            }
        }
    }
    
    private var dayString: String {
        Calendar.current.component(.day, from: date).description
    }
}

private struct CurrentDayIndicator: View {
    let dayString: String
    let containerWidth: CGFloat
    let accentColor: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(accentColor)
            Text(dayString)
                .font(.title3)
                .foregroundColor(.white)
        }
        .frame(width: containerWidth * 0.75, height: containerWidth * 0.75)
    }
}

private struct RegularDayText: View {
    let dayString: String
    let containerWidth: CGFloat
    
    var body: some View {
        Text(dayString)
            .font(.title3)
            .foregroundColor(.primary)
            .frame(width: containerWidth * 0.75, height: containerWidth * 0.75)
    }
}

// MARK: - Preference Key

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}

// MARK: - Detail Views

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
