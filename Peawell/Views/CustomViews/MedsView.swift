//
//  MedsView.swift
//  Peawell
//
//  Created by Dennis on 19.04.23.
//

import SwiftUI

struct MedsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    //  adds fetched data to scope
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Meds.medType, ascending: true)], animation: .default)
    var medsItems: FetchedResults<Meds>
    
    //  these define the user input field's empty state
    @State var medName: String = ""
    @State var medAmount: String = ""
    @State var medUnit: String = ""
    
    @State private var editingMed: Meds?
    
    //  defines wether sheet is shown
    @State public var showAddMedSheet = false
    
    var body: some View {
        Section(header:
                    HStack {
            Text("section.header.medList")
                .font(.headline)
            Spacer()
            Button(action: {
                showAddMedSheet = true
            }) {
                Image(systemName: "plus")
                    .font(.title2)
            }
        }
            .padding(.horizontal, 20)
        ) {
            ForEach(medsItems) { item in
                let medKind = item.medKind ?? "longPill"
                let medColorName = "\(medKind)Color"
                PanelView(
                    icon:
                        Image(medKind)
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
                .contextMenu() {
                    Button(
                        role: .destructive
                    ) {
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
                    .shadow(radius: 5, x: 0, y: 3)
            }
            .frame(maxWidth: 90, alignment: .center)
            VStack {
                Text(title)
                    .font(.title3)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(doseAmnt + " " + doseUnit)
                    .font(.title3)
                    .foregroundColor(Color.secondary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
            ZStack {
                if showTick {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .symbolRenderingMode(.hierarchical)
                        .frame(width: 30, height: 30)
                        .frame(maxWidth: 90, alignment: .center)
                } else {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .symbolRenderingMode(.hierarchical)
                        .frame(width: 30, height: 30)
                        .frame(maxWidth: 90, alignment: .center)
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
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    MedsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
