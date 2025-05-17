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
                TextEditor(text: $actName)
                    .frame(minHeight: 100)

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
                            Label(NSLocalizedString("mood.picker.save", comment: "tells the user this button saves entry"), systemImage: "plus")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.accentColor.opacity(0.3))
                                .foregroundColor(Color.accentColor)
                                .clipShape(RoundedRectangle(cornerRadius: 100))
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
                            Label(NSLocalizedString("mood.picker.cancel", comment: "tells the user this button cancels input"), systemImage: "xmark.circle")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.tertiarySystemBackground)
                                .foregroundColor(Color.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 100))
                        }
                    )
                }
            }
            
        }
        .padding()
        .background(Color.secondarySystemBackground)
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
                        .shadow(radius: isSelected ? 4 : 0)
                } else {
                    // Show grayed out circle
                    Circle()
                        .foregroundColor(panelColor)
                        .aspectRatio(1, contentMode: .fit)
                        .saturation(0)
                        .opacity(0.3)
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.5), lineWidth: 2)
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
