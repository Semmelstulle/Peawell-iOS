//
//  MoodPickerView.swift
//  Peawell
//
//  Created by Dennis on 17.04.23.
//

import SwiftUI

struct MoodPickerView: View {
    
    // parsed moods
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Mood.moodName, ascending: true)], animation: .default)
    var items: FetchedResults<Mood>
    
    // state of the variables that will be updated by code
    @State var moodName: String = ""
    @State var actName: String = ""
    @State var moodLogDate: Date = Date()
    @State var showMoodField: Bool = false
    
    // prepares colors
    var bgColorHorrible: Color = Color.red
    var bgColorBad: Color = Color.orange
    var bgColorNeutral: Color = Color.yellow
    var bgColorGood: Color = Color.green
    var bgColorAwesome: Color = Color.mint
    
    // this sets up colors for the part where you pick a mood and it turns the others grayscale
    let moodOptions: [(color: Color, name: String, image: String)] = [
        (.red, "Horrible", "moodHorrible"),
        (.orange, "Bad", "moodBad"),
        (.yellow, "Neutral", "moodNeutral"),
        (.green, "Good", "moodGood"),
        (.mint, "Awesome", "moodAwesome")
    ]
    
    var body: some View {
        VStack {
            Text(NSLocalizedString("mood.picker.prompt", comment: "ask for the daily, AVERAGE mood"))
                .padding(.bottom, 10)
            HStack {
                ForEach(moodOptions, id: \.name) { option in
                    MoodButtonView(
                        panelColor: option.color,
                        moodImage: option.image,
                        moodName: option.name,
                        isSelected: moodName == option.name,
                        anySelected: !moodName.isEmpty,
                        onTap: {
                            if moodName == option.name {
                                moodName = ""
                                showMoodField = false
                            } else {
                                moodName = option.name
                                withAnimation(.bouncy(duration: 0.2)) {
                                    showMoodField = true
                                }
                            }
                        }
                    )
                    .animation(.easeInOut, value: moodName)
                }
            }

            if showMoodField == true {
                Text(
                    String(format: NSLocalizedString("mood.picker.prompt.prefix ", comment: "prefix, asks in natural language for what happened today")) +
                    String(format: NSLocalizedString(moodName, comment: "name of mood")) +
                    String(format: NSLocalizedString(" mood.picker.prompt.suffix", comment: "suffix, asks in natural language for what happened today"))
                )
                .padding(.vertical, 10)
                TextEditor(text: $actName)
                    .frame(minHeight: 100)
                    .padding(.bottom, 10)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                //  custom save and discard buttons
                HStack {
                    Button(
                        action: {
                            saveMood(actName: actName, moodName: moodName, moodLogDate: moodLogDate)
                            withAnimation(.bouncy(duration: 0.2)) {
                                showMoodField = false
                            }
                            moodName = ""
                            actName = ""
                            hapticConfirm()
                        },
                        label: {
                            Text(NSLocalizedString("mood.picker.save", comment: "tells the user this button saves entry"))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.accentColor.opacity(0.3))
                                .foregroundColor(Color.accentColor)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    )
                    Button(
                        action: {
                            withAnimation(.bouncy(duration: 0.2)) {
                                showMoodField = false
                            }
                            moodName = ""
                            actName = ""
                            moodLogDate = Date.now
                        },
                        label: {
                            Text(NSLocalizedString("mood.picker.cancel", comment: "tells the user this button cancels input"))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemBackground))
                                .foregroundColor(Color.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    )
                }
            }
            
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

//  prepares the mood cell
struct MoodButtonView: View {
    let panelColor: Color
    let moodImage: String
    let moodName: String
    let isSelected: Bool
    let anySelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                if !anySelected || isSelected {
                    // Show colorful rounded rectangle
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .foregroundColor(panelColor)
                        .aspectRatio(1, contentMode: .fit)
                        .shadow(color: panelColor.opacity(0.5), radius: isSelected ? 6 : 0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                } else {
                    // Show grayed out circle
                    Circle()
                        .foregroundColor(panelColor)
                        .aspectRatio(1, contentMode: .fit)
                        .saturation(0)
                        .opacity(0.3)
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                }
                Image(moodImage)
                    .resizable()
                    .scaledToFit()
                    .padding(12)
                    .opacity((!anySelected || isSelected) ? 1 : 0.5)
                    .saturation((!anySelected || isSelected) ? 1 : 0)
            }
        }
        .buttonStyle(.plain)
    }
}



#Preview {
    MoodPickerView()
}
