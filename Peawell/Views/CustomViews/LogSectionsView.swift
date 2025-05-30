//
//  CalendarView.swift
//  Peawell
//
//  Created by Dennis on 14.05.25.
//

import SwiftUI

enum TileDestination: Hashable {
    case mood
    case med
}

struct LogSectionsView: View {
    @AppStorage("settingShowMoodSection") private var settingShowMoodSection = true
    @AppStorage("settingShowMedicationSection") private var settingShowMedicationSection = true
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Mood.logDate, ascending: false)], animation: .default)
    private var moodItems: FetchedResults<Mood>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Meds.medType, ascending: true)], animation: .default)
    private var medsItems: FetchedResults<Meds>
    
    var body: some View {
        HStack(spacing: 16) {
            if settingShowMoodSection {
                TileButton(
                    iconName: "3dDiary",
                    title: LocalizedStringKey("title.diary"),
                    count: moodItems.count,
                    gradient: LinearGradient(
                        colors: [.orange, .yellow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    value: .mood
                )
            }
            if settingShowMedicationSection {
                TileButton(
                    iconName: "3dMedication",
                    title: LocalizedStringKey("title.med"),
                    count: medsItems.count,
                    gradient: LinearGradient(
                        colors: [.mint, .teal],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    value: .med
                )
            }
        }
        .navigationDestination(for: TileDestination.self) { destination in
            switch destination {
            case .mood:
                MoodLogView()
            case .med:
                MedLogView()
            }
        }
    }
}

struct TileButton: View {
    let iconName: String
    let title: LocalizedStringKey
    let count: Int
    let gradient: LinearGradient
    let value: TileDestination
    
    var body: some View {
        NavigationLink(value: value) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(gradient)
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        Image(iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                        Spacer()
                        HStack(spacing: 4) {
                            Text("\(count)")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(4)
                    }
                    .padding(12)
                    Text(title)
                        .font(.body.bold())
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .padding([.trailing, .leading, .bottom], 12)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    LogSectionsView()
}
