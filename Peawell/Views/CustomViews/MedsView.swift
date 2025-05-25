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
        ZStack {
            //  grid that replicates what Passwords and Reminders do
            //  on the top
            LazyVGrid(columns: [.init(spacing: 16), .init(spacing: 16)], spacing: 16) {
                ForEach(medsItems) { item in
                    PanelView(
                        icon:
                            Image(item.medKind ?? "longPill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding(5)
                            .background(Color.accentColor)
                            .clipShape(Circle()),
                        doseAmnt: String(item.medDose ?? ""),
                        doseUnit: String(item.medUnit ?? ""),
                        title: String(item.medType ?? "")
                    )
                    .modifier(BounceAnimationModifier {
                        hapticConfirm()
                        logMedicationIntake(for: item)
                    })
                    .contextMenu() {
                        Button(
                            role: .destructive
                        ) {
                            trashItem(objectID: item.objectID)
                        } label: {
                            Label(NSLocalizedString("med.trash.item", comment: "tells user that action trashes medication"), systemImage: "trash")
                        }
                        Button {
                            editingMed = item
                        } label: {
                            Label(NSLocalizedString("med.edit.item", comment: "tells user that action edits the medication"), systemImage: "square.and.pencil")
                        }
                    }
                }
                //  custom cell that is here for adding new meds
                PanelView(
                    icon:
                        Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Color.accentColor)
                        .clipShape(Circle()),
                    doseAmnt: String(medsItems.count),
                    doseUnit: "",
                    title: String(format: NSLocalizedString("med.add.item", comment: "tells user that button adds item"))
                )
                .onTapGesture {
                    showAddMedSheet = true
                }
                .sheet(isPresented: $showAddMedSheet) {
                    ModifyMedsSheetView()
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.hidden)
                }
                .sheet(item: $editingMed) { med in
                    ModifyMedsSheetView(med: med)
                }

            }
        }
    }
    private func logMedicationIntake(for medication: Meds) {
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
    struct BounceAnimationModifier: ViewModifier {
        let action: () -> Void
        @State private var isTapped = false
        
        init(action: @escaping () -> Void) {
            self.action = action
        }
        func body(content: Content) -> some View {
            content
                .scaleEffect(isTapped ? 0.9 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isTapped)
                .simultaneousGesture(
                    TapGesture()
                        .onEnded {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                isTapped = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                    isTapped = false
                                }
                            }
                            action()
                        }
                )
        }
    }
}

//  defines single cell for the grid #reusableCode
struct PanelView<V: View>: View { var icon: V; var doseAmnt: String; var doseUnit: String; var title: String;
    var body: some View {
        VStack {
            HStack() {
                icon
                Spacer()
                Text(doseAmnt + " " + doseUnit)
                    .font(.title3)
                    .foregroundColor(Color.secondary)
                    .lineLimit(1)
            }
            Text(title)
                .padding(.top, 5)
                .font(.title3)
                .foregroundColor(.primary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

struct MedsView_Previews: PreviewProvider {
    static var previews: some View {
        MedsView()
    }
}
