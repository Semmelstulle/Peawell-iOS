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
    
    // receive moodName from parent
    var moodName: String
    var actName: String = ""
    var moodLogDate: Date = Date()
    var selectedCategories: Set<MoodCategory> = []
    var onSave: ((_ actName: String, _ moodName: String, _ moodLogDate: Date, _ selectedCategories: [MoodCategory]) -> Void)? = nil
    var onDismiss: (() -> Void)? = nil
    
    @AppStorage("selectedAccentColor") private var selectedAccentColor: String = "AccentColor"
    
    // Use states for edit/copy/new
    @State private var editingActName: String = ""
    @State private var editingMoodLogDate: Date = Date()
    @State private var editingSelectedCategories: Set<MoodCategory> = []
    @State private var currentPage = 0
    
    // Demo chips (could be dynamic)
    let demoCategories: [MoodCategory] = [
        //  initial categories, removal causes issues
        MoodCategory(name: "Happy", sfsymbol: "smiley"),
        MoodCategory(name: "Sad", sfsymbol: "cloud.rain"),
        MoodCategory(name: "Energetic", sfsymbol: "bolt"),
        MoodCategory(name: "Running", sfsymbol: "figure.run"),
        MoodCategory(name: "Gaming", sfsymbol: "gamecontroller"),
        MoodCategory(name: "Interaction", sfsymbol: "person.2"),
        MoodCategory(name: "Sunset", sfsymbol: "sun.haze"),
        MoodCategory(name: "Movie/Show", sfsymbol: "play.rectangle"),
        MoodCategory(name: "Code", sfsymbol: "command.square"),
        //  new additions
        MoodCategory(name: "Food", sfsymbol: "fork.knife"),
        MoodCategory(name: "Home", sfsymbol: "house"),
        MoodCategory(name: "Work", sfsymbol: "calendar"),
        MoodCategory(name: "Sun", sfsymbol: "sun.max"),
        MoodCategory(name: "Rain", sfsymbol: "cloud.drizzle"),
        MoodCategory(name: "Snow", sfsymbol: "snowflake"),
        MoodCategory(name: "Hot", sfsymbol: "thermometer.sun"),
        MoodCategory(name: "Freezing", sfsymbol: "thermometer.snowflake"),
        MoodCategory(name: "Rainbow", sfsymbol: "rainbow"),
        MoodCategory(name: "Travel", sfsymbol: "map"),
        MoodCategory(name: "Bike", sfsymbol: "bicycle"),
        MoodCategory(name: "Exploration", sfsymbol: "binoculars"),
        MoodCategory(name: "Shower", sfsymbol: "shower.handheld"),
        MoodCategory(name: "Bath", sfsymbol: "bathtub"),
        MoodCategory(name: "Car", sfsymbol: "car"),
        MoodCategory(name: "Vacation", sfsymbol: "airplane"),
        MoodCategory(name: "Selfcare", sfsymbol: "person"),
        MoodCategory(name: "Cardio", sfsymbol: "figure.walk.treadmill"),
        MoodCategory(name: "Strength", sfsymbol: "figure.strengthtraining.traditional"),
        MoodCategory(name: "Core", sfsymbol: "figure.core.training"),
        MoodCategory(name: "Mindfulness", sfsymbol: "eye"),
        MoodCategory(name: "Allergens", sfsymbol: "allergens"),
        MoodCategory(name: "Dog", sfsymbol: "dog"),
        MoodCategory(name: "Cat", sfsymbol: "cat"),
        MoodCategory(name: "Bird", sfsymbol: "bird"),
        MoodCategory(name: "Animal", sfsymbol: "pawprint"),
        MoodCategory(name: "Romance", sfsymbol: "heart"),
        MoodCategory(name: "Sick", sfsymbol: "facemask")
    ]
    
    // Fill initial values from parent
    init(
        moodName: String,
        actName: String = "",
        moodLogDate: Date = Date(),
        selectedCategories: Set<MoodCategory> = [],
        onSave: ((_ actName: String, _ moodName: String, _ moodLogDate: Date, _ selectedCategories: [MoodCategory]) -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.moodName = moodName
        self.actName = actName
        self.moodLogDate = moodLogDate
        self.selectedCategories = selectedCategories
        self.onSave = onSave
        self.onDismiss = onDismiss
        // Note: SwiftUI will not auto-assign @State from this init directly!
        // So we will push these values in .onAppear below.
    }
    
    var body: some View {
        NavigationStack {
            TabView(selection: $currentPage) {
                textboxTab()
                    .tag(0)
                chipsTab()
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            AccessoryProminentButtonBig(
                title: currentPage == 0 ? NSLocalizedString("button.next", comment: "") : NSLocalizedString("button.mood.save", comment: ""),
                systemImage: "square.and.pencil",
                action: {
                    if currentPage == 0 {
                        withAnimation {
                            currentPage = 1
                        }
                    } else {
                        if let onSave = onSave {
                            onSave(editingActName, moodName, editingMoodLogDate, Array(editingSelectedCategories))
                        } else {
                            saveMood(actName: editingActName, moodName: moodName, moodLogDate: editingMoodLogDate, selectedCategories: Array(editingSelectedCategories))
                        }
                        clearInputs()
                        dismiss()
                        onDismiss?()
                    }
                }
            )
            .navigationTitle("title.mood")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                DismissToolbarButton(
                    action: {
                        clearInputs()
                        dismiss()
                        onDismiss?()
                    }
                )
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .onAppear {
            // Only assign once for editing, to avoid overwriting user data on tab switch
            if editingActName.isEmpty && !actName.isEmpty {
                editingActName = actName
            }
            if abs(editingMoodLogDate.timeIntervalSince1970 - moodLogDate.timeIntervalSince1970) > 10 {
                editingMoodLogDate = moodLogDate
            }
            if editingSelectedCategories.isEmpty && !selectedCategories.isEmpty {
                editingSelectedCategories = selectedCategories
            }
        }
        .accentColor(Color(UIColor(named: selectedAccentColor) ?? .green))
        .onDisappear {
            clearInputs()
            onDismiss?()
        }
    }
    
    private func clearInputs() {
        editingActName = ""
        editingSelectedCategories = []
    }
    
    @ViewBuilder
    func chipsTab() -> some View {
        ScrollView {
            FlowLayout {
                ForEach(demoCategories) { category in
                    ChipView(
                        category: category,
                        isSelected: editingSelectedCategories.contains(category),
                        onTap: {
                            if editingSelectedCategories.contains(category) {
                                editingSelectedCategories.remove(category)
                            } else {
                                editingSelectedCategories.insert(category)
                            }
                        }
                    )
                }
            }
            .padding()
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
    
    @ViewBuilder
    func textboxTab() -> some View {
        VStack(spacing: 0) {
            DatePicker("",
                       selection: $editingMoodLogDate,
                       displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            ZStack(alignment: .topLeading) {
                TextEditor(text: $editingActName)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.cornerRadiusPrimary, style: .continuous)
                            .fill(Color(.tertiarySystemGroupedBackground))
                    )
                    .scrollContentBackground(.hidden)
                    .foregroundColor(.primary)
                if editingActName.isEmpty {
                    Text("mood.textEditor.whatMadeYouSmile")
                        .foregroundColor(.secondary)
                        .padding([.horizontal, .vertical], 16)
                }
            }
            .padding([.top, .horizontal])
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// prepares the mood cell
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
                    RoundedRectangle(
                        cornerRadius: Constants.cornerRadiusSecondary,
                        style: .continuous
                    )
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
    MoodPickerView(moodName: "moodAwesome")
}
