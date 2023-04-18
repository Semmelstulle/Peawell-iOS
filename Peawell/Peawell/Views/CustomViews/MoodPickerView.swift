//
//  MoodPickerView.swift
//  Peawell
//
//  Created by Dennis on 17.04.23.
//

import SwiftUI

struct MoodPickerView: View {
    var body: some View {
        VStack {
            HStack {
                MoodButtonView(panelColor: Color.red, moodImage: "pipette")
                MoodButtonView(panelColor: Color.orange, moodImage: "pipette")
                MoodButtonView(panelColor: Color.gray, moodImage: "pipette")
                MoodButtonView(panelColor: Color.yellow, moodImage: "pipette")
                MoodButtonView(panelColor: Color.green, moodImage: "pipette")
            }
            TextField()
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
