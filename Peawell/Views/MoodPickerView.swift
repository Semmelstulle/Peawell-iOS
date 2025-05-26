//
//  MoodPickerView.swift
//  Peawell
//
//  Created by Dennis on 17.04.23.
//

import SwiftUI

struct MoodPickerView: View {
    @Environment(\.dismiss) private var dismiss
    
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
        NavigationStack {
            Form {
                Section(header:
                            Text("mood.header.howDidYouFeel")
                ) {
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
                                    } else {
                                        moodName = option.name
                                    }
                                }
                            )
                            .animation(.easeInOut, value: moodName)
                        }
                    }
                }
                Section {
                    // Make the TextEditor expand
                    ZStack(alignment: .topLeading) {
                        if actName.isEmpty {
                            Text("mood.textEditor.whatMadeYouSmile")
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 12)
                        }
                        TextEditor(text: $actName)
                            .frame(minHeight: 100, maxHeight: .infinity, alignment: .top)
                            .padding(4)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .listRowInsets(EdgeInsets())
                }
                Section {
                    Button(
                        action: {
                            saveMood(actName: actName, moodName: moodName, moodLogDate: moodLogDate)
                            clearInputs()
                            dismiss()
                        },
                        label: {
                            Label("button.mood.save", systemImage: "plus")
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                        }
                    )
                }
                .listRowBackground(Color.accentColor.opacity(0.3))
            }
            .navigationTitle("title.mood")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        clearInputs()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                            .font(.system(size: 25))
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }
    private func clearInputs() {
        moodName = ""
        actName = ""
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
                } else {
                    // Show grayed out circle
                    Circle()
                        .foregroundColor(panelColor)
                        .aspectRatio(1, contentMode: .fit)
                        .saturation(0)
                        .opacity(0.3)
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
