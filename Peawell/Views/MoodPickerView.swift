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
        MoodCategory(name: "Happy", sfsymbol: "smiley"),
        MoodCategory(name: "Sad", sfsymbol: "cloud.rain"),
        MoodCategory(name: "Energetic", sfsymbol: "bolt.fill"),
        MoodCategory(name: "Running", sfsymbol: "figure.run"),
        MoodCategory(name: "Gaming", sfsymbol: "gamecontroller.fill"),
        MoodCategory(name: "Interaction", sfsymbol: "person.2.fill"),
        MoodCategory(name: "Sunset", sfsymbol: "sun.haze.fill"),
        MoodCategory(name: "Movie/Show", sfsymbol: "play.rectangle.fill"),
        MoodCategory(name: "Code", sfsymbol: "command.square.fill")
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
            .navigationTitle("title.mood")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                dismissButton()
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
        VStack {
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
            saveButton()
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
            nextButton()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    func nextButton() -> some View {
        if #available(iOS 26.0, *) {
            Button(
                action: {
                    withAnimation {
                        currentPage = 1
                    }
                }, label: {
                    Label("button.next", systemImage: "arrow.right")
                        .font(.headline)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                }
            )
            .padding()
            .buttonStyle(.glassProminent)
        } else {
            Button(
                action: {
                    currentPage = 1
                }, label: {
                    Label("button.next", systemImage: "arrow.right")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            )
            .padding()
        }
    }
    
    @ViewBuilder
    func saveButton() -> some View {
        if #available(iOS 26.0, *) {
            Button(
                action: {
                    if let onSave = onSave {
                        onSave(editingActName, moodName, editingMoodLogDate, Array(editingSelectedCategories))
                    } else {
                        saveMood(actName: editingActName, moodName: moodName, moodLogDate: editingMoodLogDate, selectedCategories: Array(editingSelectedCategories))
                    }
                    clearInputs()
                    dismiss()
                    onDismiss?()
                }, label: {
                    Label("button.mood.save", systemImage: "square.and.pencil")
                        .font(.headline)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                }
            )
            .padding()
            .buttonStyle(.glassProminent)
        } else {
            Button(
                action: {
                    if let onSave = onSave {
                        onSave(editingActName, moodName, editingMoodLogDate, Array(editingSelectedCategories))
                    } else {
                        saveMood(actName: editingActName, moodName: moodName, moodLogDate: editingMoodLogDate, selectedCategories: Array(editingSelectedCategories))
                    }
                    clearInputs()
                    dismiss()
                    onDismiss?()
                }, label: {
                    Label("button.mood.save", systemImage: "square.and.pencil")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            )
            .padding()
        }
    }

    private func dismissButton() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if #available(iOS 26.0, *) {
                Button {
                    clearInputs()
                    dismiss()
                    onDismiss?()
                } label: {
                    Image(systemName: "xmark")
                }
            } else {
                Button {
                    clearInputs()
                    dismiss()
                    onDismiss?()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray)
                        .font(.system(size: 25))
                        .symbolRenderingMode(.hierarchical)
                }
            }
        }
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
