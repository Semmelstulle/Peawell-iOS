//
//  MedsView.swift
//  Peawell
//
//  Created by Dennis on 19.04.23.
//

import SwiftUI

struct MedsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Meds.medType, ascending: true)],
        animation: .default
    )
    private var medsItems: FetchedResults<Meds>
    
    @State private var editingMed: Meds?
    @State private var showAddMedSheet = false
    
    @State private var showMedLogSheet = false
    @State private var medToLog: Meds?
    @State private var selectedDate = Date()
    
    var body: some View {
        Section(header: sectionHeader) {
            ForEach(medsItems) { item in
                let medKind = item.medKind ?? "longPill"
                let medColorName = "\(medKind)Color"
                PanelView(
                    icon: Image(medKind)
                        .resizable()
                        .scaledToFit(),
                    medColor: Color(medColorName),
                    doseAmnt: String(item.medDose ?? ""),
                    doseUnit: String(item.medUnit ?? ""),
                    title: LocalizedStringKey(item.medType ?? ""),
                    onPlusTap: {
                        medToLog = item
                        selectedDate = Date()
                        showMedLogSheet = true
                    }
                )
                .contextMenu {
                    Button(role: .destructive) {
                        trashItem(objectID: item.objectID)
                    } label: {
                        Label("med.trash.item", systemImage: "trash")
                    }
                    Button {
                        editingMed = item
                    } label: {
                        Label("med.edit.item", systemImage: "square.and.pencil")
                    }
                }
            }
        }
        .listStyle(.plain)
        .sheet(isPresented: $showAddMedSheet) {
            ModifyMedsSheetView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
        .sheet(item: $editingMed) { med in
            ModifyMedsSheetView(med: med)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showMedLogSheet) {
            MedLogDatePickerSheet(
                selectedDate: $selectedDate,
                onSave: {
                    if let med = medToLog {
                        logMedicationIntake(for: med, at: selectedDate)
                    }
                    showMedLogSheet = false
                    hapticConfirm()
                },
                onDismiss: {
                    showMedLogSheet = false
                }
            )
            .presentationDetents([.height(260)])
            .presentationDragIndicator(.hidden)
            .interactiveDismissDisabled()
        }
    }
    
    private var sectionHeader: some View {
        HStack {
            Text("title.med")
                .font(.title2.bold())
            Spacer()
            Button(action: { showAddMedSheet = true }) {
                Image(systemName: "plus")
                    .font(.title2)
            }
        }
        .padding(.horizontal, 4)
    }
    
    private func logMedicationIntake(for medication: Meds?, at date: Date = Date()) {
        guard let medication = medication else { return }
        let newLog = LogTimeMeds(context: viewContext)
        newLog.logTimes = date
        newLog.medication = medication
        medication.addToLogTimes(newLog)
        do {
            try viewContext.save()
            medication.objectWillChange.send()
        } catch {
            print("Error saving log: \(error)")
        }
    }
}

//  defines single cell for the grid #reusableCode
struct PanelView<V: View>: View {
    var icon: V
    var medColor: Color
    var doseAmnt: String
    var doseUnit: String
    var title: LocalizedStringKey
    var onPlusTap: (() -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .center) {
            ZStack {
                Rectangle()
                    .fill(medColor)
                    .scaledToFit()
                icon
                    .frame(width: 42, height: 42)
                    .shadow(radius: 4, x: 0, y: 2)
            }
            .frame(maxWidth: 80, alignment: .center)
            VStack {
                Text(title)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(doseAmnt + " " + doseUnit)
                    .foregroundColor(Color.secondary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 8)
            Image(systemName: "plus.circle.fill")
                .resizable()
                .scaledToFit()
                .symbolRenderingMode(.hierarchical)
                .frame(width: 30, height: 30)
                .frame(maxWidth: 80, alignment: .center)
                .onTapGesture {
                    onPlusTap?()
                }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(
            RoundedRectangle(cornerRadius: Constants.cornerRadiusPrimary)
        )
    }
}

struct MedLogDatePickerSheet: View {
    @Binding var selectedDate: Date
    var onSave: () -> Void
    var onDismiss: () -> Void
    var body: some View {
        NavigationStack {
            ZStack {
                HStack {
                    Spacer()
                    DatePicker(
                        "",
                        selection: $selectedDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    DismissToolbarButton(action: onDismiss)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    DoneToolbarButton(action: onSave)
                }
            }
        }
    }
}

#Preview {
    MedsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
