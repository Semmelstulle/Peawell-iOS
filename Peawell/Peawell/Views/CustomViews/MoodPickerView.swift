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
    @State var showMoodField: Bool = false

    var body: some View {
        VStack {
            Text("How's your mood today?")
            HStack {
                MoodButtonView(panelColor: Color.red, moodImage: "moodHorrible")
                    .onTapGesture {
                        moodName = "Horrible"
                        withAnimation(.easeOut(duration: 0.2)) {
                            showMoodField = true
                        }
                    }
                MoodButtonView(panelColor: Color.orange, moodImage: "moodBad")
                    .onTapGesture {
                        moodName = "Bad"
                        withAnimation(.easeOut(duration: 0.2)) {
                            showMoodField = true
                        }
                    }
                MoodButtonView(panelColor: Color.yellow, moodImage: "moodNeutral")
                    .onTapGesture {
                        moodName = "Neutral"
                        withAnimation(.easeOut(duration: 0.2)) {
                            showMoodField = true
                        }
                    }
                MoodButtonView(panelColor: Color.green, moodImage: "moodGood")
                    .onTapGesture {
                        moodName = "Good"
                        withAnimation(.easeOut(duration: 0.2)) {
                            showMoodField = true
                        }
                    }
                MoodButtonView(panelColor: Color.mint, moodImage: "moodAwesome")
                    .onTapGesture {
                        moodName = "Awesome"
                        withAnimation(.easeOut(duration: 0.2)) {
                            showMoodField = true
                        }
                    }
            }
            if showMoodField == true {
                TextField(
                    text: $actName,
                    prompt: Text("What did you do today?")
                ) {
                    Text("Activity name")
                }
                .padding()
                .background(Color.tertiarySystemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                HStack {
                    Button(action: {
                        saveMood(actName: actName, moodName: moodName)
                        withAnimation(.easeOut(duration: 0.2)) {
                            showMoodField = false
                        }
                    }, label: {
                        Label("Add activity", systemImage: "plus")
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    })
                    Button(action: {
                        moodName = ""
                        actName = ""
                        withAnimation(.easeOut(duration: 0.2)) {
                            showMoodField = false
                        }
                    }, label: {
                        Label("Cancel", systemImage: "xmark.circle")
                            .padding()
                            .background(Color.tertiarySystemBackground)
                            .foregroundColor(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    })
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
