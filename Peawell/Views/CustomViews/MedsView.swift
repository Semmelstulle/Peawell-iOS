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
                        hapticConfirm()
                        logMedicationIntake(for: item)
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
    
    private func logMedicationIntake(for medication: Meds?) {
        guard let medication = medication else { return }
        let newLog = LogTimeMeds(context: viewContext)
        newLog.logTimes = Date()
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
    
    @State private var showTick = false
    
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
            ZStack {
                if showTick {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .symbolRenderingMode(.hierarchical)
                        .frame(width: 30, height: 30)
                        .frame(maxWidth: 80, alignment: .center)
                } else {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .symbolRenderingMode(.hierarchical)
                        .frame(width: 30, height: 30)
                        .frame(maxWidth: 80, alignment: .center)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showTick = true
                            }
                            onPlusTap?()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showTick = false
                                }
                            }
                        }
                }
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    MedsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
