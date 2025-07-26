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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DatePicker("",
                    selection: $moodLogDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                //.datePickerStyle(.compact)
                .datePickerStyle(.automatic)
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
                if #available(iOS 26.0, *) {
                    Button(
                        action: {
                            saveMood(actName: actName, moodName: moodName, moodLogDate: moodLogDate)
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
                            saveMood(actName: actName, moodName: moodName, moodLogDate: moodLogDate)
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
            .onAppear {
                if actName.isEmpty && (moodLogDate.timeIntervalSinceNow > 60 || moodLogDate.timeIntervalSinceNow < -60) {
                    moodLogDate = Date()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("title.mood")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if #available(iOS 26.0, *) {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            clearInputs()
                            dismiss()
                            onDismiss?()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                } else {
                    ToolbarItem(placement: .topBarTrailing) {
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
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }
    private func clearInputs() {
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
