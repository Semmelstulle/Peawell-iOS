//
//  MoodPickerView.swift
//  Peawell
//
//  Created by Dennis on 17.04.23.
//

import SwiftUI

struct MoodPickerView: View {
    
    //  parsed moods
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Mood.moodName, ascending: true)], animation: .default)
    var items: FetchedResults<Mood>
    
    //  state of the variables that will be updated by code
    @State var moodName: String = ""
    @State var actName: String = ""
    @State var moodLogDate: Date = Date()
    @State var showMoodField: Bool = false
    
    //  prepares colors
    var bgColorHorrible: Color = Color.red
    var bgColorBad: Color = Color.orange
    var bgColorNeutral: Color = Color.yellow
    var bgColorGood: Color = Color.green
    var bgColorAwesome: Color = Color.mint
    
    var body: some View {
        VStack {
            Text(NSLocalizedString("mood.picker.prompt", comment: "ask for the daily, AVERAGE mood"))
            HStack {
                MoodButtonView(panelColor: bgColorHorrible, moodImage: "moodHorrible")
                    .onTapGesture {
                        moodName = "Horrible"
                        withAnimation(.bouncy(duration: 0.2)) {
                            showMoodField = true
                        }
                    }
                MoodButtonView(panelColor: bgColorBad, moodImage: "moodBad")
                    .onTapGesture {
                        moodName = "Bad"
                        withAnimation(.bouncy(duration: 0.2)) {
                            showMoodField = true
                        }
                    }
                MoodButtonView(panelColor: bgColorNeutral, moodImage: "moodNeutral")
                    .onTapGesture {
                        moodName = "Neutral"
                        withAnimation(.bouncy(duration: 0.2)) {
                            showMoodField = true
                        }
                    }
                MoodButtonView(panelColor: bgColorGood, moodImage: "moodGood")
                    .onTapGesture {
                        moodName = "Good"
                        withAnimation(.bouncy(duration: 0.2)) {
                            showMoodField = true
                        }
                    }
                MoodButtonView(panelColor: bgColorAwesome, moodImage: "moodAwesome")
                    .onTapGesture {
                        moodName = "Awesome"
                        withAnimation(.bouncy(duration: 0.2)) {
                            showMoodField = true
                        }
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
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
                .background(Color.tertiarySystemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                HStack {
                    Button(
                        action: {
                            saveMood(actName: actName, moodName: moodName, moodLogDate: moodLogDate)
                            withAnimation(.bouncy(duration: 0.2)) {
                                showMoodField = false
                            }
                            hapticConfirm()
                        },
                        label: {
                            Label(NSLocalizedString("mood.picker.save", comment: "tells the user this button saves entry"), systemImage: "plus")
                                .padding()
                                .background(Color.tertiarySystemBackground)
                                .foregroundColor(Color.accentColor)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
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
                                .background(Color.tertiarySystemBackground)
                                .foregroundColor(Color.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
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

//  prepares the day cell
struct MoodButtonView: View {
    @State var panelColor: Color
    @State var moodImage : String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous).foregroundColor(panelColor).aspectRatio(1, contentMode: .fit);
            Image(moodImage)
        }
    }
}

struct MoodPickerView_Previews: PreviewProvider {
    static var previews: some View {
        MoodPickerView()
    }
}
