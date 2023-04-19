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

    //  prepares colors
    var bgColorHorrible: Color = Color.red
    var bgColorBad: Color = Color.orange
    var bgColorNeutral: Color = Color.yellow
    var bgColorGood: Color = Color.green
    var bgColorAwesome: Color = Color.mint

    var body: some View {
        VStack {
            Text("How's your average mood today?")
            HStack {
                MoodButtonView(panelColor: bgColorHorrible, moodImage: "moodHorrible")
                    .onTapGesture {
                        moodName = "Horrible"
                        withAnimation(.easeOut(duration: 0.2)) {
                            showMoodField = true
                        }
                    }
                MoodButtonView(panelColor: bgColorBad, moodImage: "moodBad")
                    .onTapGesture {
                        moodName = "Bad"
                        withAnimation(.easeOut(duration: 0.2)) {
                            showMoodField = true
                        }
                    }
                MoodButtonView(panelColor: bgColorNeutral, moodImage: "moodNeutral")
                    .onTapGesture {
                        moodName = "Neutral"
                        withAnimation(.easeOut(duration: 0.2)) {
                            showMoodField = true
                        }
                    }
                MoodButtonView(panelColor: bgColorGood, moodImage: "moodGood")
                    .onTapGesture {
                        moodName = "Good"
                        withAnimation(.easeOut(duration: 0.2)) {
                            showMoodField = true
                        }
                    }
                MoodButtonView(panelColor: bgColorAwesome, moodImage: "moodAwesome")
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
                        hapticConfirm()
                    }, label: {
                        Label("Add activity", systemImage: "plus")
                            .padding(10)
                            .background(Color.tertiarySystemBackground)
                            .foregroundColor(Color.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    })
                    Button(action: {
                        moodName = ""
                        actName = ""
                        withAnimation(.easeOut(duration: 0.2)) {
                            showMoodField = false
                        }
                        hapticConfirm()
                    }, label: {
                        Label("Cancel", systemImage: "xmark.circle")
                            .padding(10)
                            .background(Color.tertiarySystemBackground)
                            .foregroundColor(Color.red)
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
