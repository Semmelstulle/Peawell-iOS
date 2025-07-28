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
    var onDismiss: (() -> Void)? = nil
    
    @State var actName: String = ""
    @State var moodLogDate: Date = Date()
        
    // remembers selected chips
    @State private var selectedCategories = Set<MoodCategory>()

    // sets default page
    @State private var currentPage = 0
    
    // ADDED: Hardcoded demo chips array
    let demoCategories: [MoodCategory] = [
        MoodCategory(name: "Happy", sfsymbol: "smiley", isBuiltIn: true),
        MoodCategory(name: "Sad", sfsymbol: "cloud.rain", isBuiltIn: true),
        MoodCategory(name: "Energetic", sfsymbol: "bolt.fill", isBuiltIn: true),
        MoodCategory(name: "Running", sfsymbol: "figure.run", isBuiltIn: true),
        MoodCategory(name: "Gaming", sfsymbol: "gamecontroller.fill", isBuiltIn: true),
        MoodCategory(name: "Interaction", sfsymbol: "person.2.fill", isBuiltIn: true),
        MoodCategory(name: "Sunset", sfsymbol: "sun.haze.fill", isBuiltIn: true),
        MoodCategory(name: "Movie/Show", sfsymbol: "play.rectangle.fill", isBuiltIn: true),
        MoodCategory(name: "Code", sfsymbol: "command.square.fill", isBuiltIn: true)
    ]
    
    var body: some View {
        NavigationStack {
            TabView(selection: $currentPage) {
                chipsTab()
                    .tag(0)
                textboxTab()
                    .tag(1)
            }
            // setting id prevents resetting to tag(0) when sheet gets resized eg when keyboard pops up
            .id("MoodPickerTabView")
            .tabViewStyle(.page(indexDisplayMode: .never))
            .navigationTitle("title.mood")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                dismissButton()
            }
            bottomButton()
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }
    
    private func clearInputs() {
        actName = ""
    }
    
    @ViewBuilder
    func chipsTab() -> some View {
        ScrollView {
            FlowLayout {
                ForEach(demoCategories) { category in
                    ChipView(
                        category: category,
                        isSelected: selectedCategories.contains(category),
                        onTap: {
                            if selectedCategories.contains(category) {
                                selectedCategories.remove(category)
                            } else {
                                selectedCategories.insert(category)
                            }
                        }
                    )
                }
            }
            .padding()
        }
    }

    
    @ViewBuilder
    func textboxTab() -> some View {
        VStack(spacing: 0) {
            DatePicker("",
                       selection: $moodLogDate,
                       displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            ZStack(alignment: .topLeading) {
                TextEditor(text: $actName)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.cornerRadiusPrimary, style: .continuous)
                            .fill(Color(.tertiarySystemGroupedBackground))
                    )
                    .scrollContentBackground(.hidden)
                    .foregroundColor(.primary)
                if actName.isEmpty {
                    Text("mood.textEditor.whatMadeYouSmile")
                        .foregroundColor(.secondary)
                        .padding([.horizontal, .vertical], 16)
                }
            }
            .padding([.top, .horizontal])
        }
        .onAppear {
            if actName.isEmpty && (moodLogDate.timeIntervalSinceNow > 60 || moodLogDate.timeIntervalSinceNow < -60) {
                moodLogDate = Date()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    func bottomButton() -> some View {
        if #available(iOS 26.0, *) {
            Button(
                action: {
                    saveMood(
                        actName: actName,
                        moodName: moodName,
                        moodLogDate: moodLogDate,
                        selectedCategories: Array(selectedCategories)
                    )
                    clearInputs()
                    dismiss()
                    onDismiss?()
                }, label: {
                    Label("button.mood.save", systemImage: "square.and.pencil")
                        .font(.headline)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                }
            )
            .padding()
            .buttonStyle(.glassProminent)
        } else {
            Button(
                action: {
                    saveMood(
                        actName: actName,
                        moodName: moodName,
                        moodLogDate: moodLogDate,
                        selectedCategories: Array(selectedCategories)
                    )
                    clearInputs()
                    dismiss()
                    onDismiss?()
                }, label: {
                    Label("button.mood.save", systemImage: "square.and.pencil")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor.opacity(0.3))
                        .foregroundColor(.accentColor)
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

// ADDED: Model representing a MoodCategory chip
struct MoodCategory: Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    var sfsymbol: String?
    var isBuiltIn: Bool = false
}

// Chip view showing name & optional SF Symbol
struct ChipView: View {
    let category: MoodCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            if let symbol = category.sfsymbol {
                Image(systemName: symbol)
                    .foregroundColor(isSelected ? .white : .accentColor)
            }
            Text(category.name)
                .foregroundColor(isSelected ? .white : .primary)
                .font(.subheadline.weight(.medium))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(isSelected ? Color.accentColor : Color(.systemGray6))
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(isSelected ? Color.accentColor : Color(.systemGray3), lineWidth: 1)
        )
        .padding(4)
        .onTapGesture {
            onTap()
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}


// FlowLayout that wraps chips on multiple rows (iOS 16+)
struct FlowLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        // Max width constrained by proposal or infinite
        let maxWidth = proposal.replacingUnspecifiedDimensions().width

        var currentRowWidth: CGFloat = 0
        var currentRowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var maxRowWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentRowWidth + size.width > maxWidth {
                // Next line
                totalHeight += currentRowHeight
                maxRowWidth = max(maxRowWidth, currentRowWidth)
                currentRowWidth = size.width
                currentRowHeight = size.height
            } else {
                currentRowWidth += size.width
                currentRowHeight = max(currentRowHeight, size.height)
            }
        }

        // Add last row
        totalHeight += currentRowHeight
        maxRowWidth = max(maxRowWidth, currentRowWidth)

        return CGSize(width: maxRowWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                // wrap to next line
                x = bounds.minX
                y += rowHeight
                rowHeight = 0
            }

            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    MoodPickerView(moodName: "moodAwesome")
}
