//
//  MedsView.swift
//  Peawell
//
//  Created by Dennis on 19.04.23.
//

import SwiftUI

struct MedsView: View {
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Meds.medType, ascending: true)], animation: .default)
    var medsItems: FetchedResults<Meds>
    //  these define the user input field's empty state
    @State var medName: String = ""
    @State var medAmount: String = ""
    @State var medUnit: String = ""

    @State var showAddMedSheet = false
    
    var body: some View {
        ZStack {
            LazyVGrid(columns: [.init(spacing: 16), .init(spacing: 16)], spacing: 16) {
                ForEach(medsItems) { item in
                    PanelView(
                        icon:
                            Image(item.medKind ?? "Long pill")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.accentColor)
                            .aspectRatio(1, contentMode: .fill)
                            .clipShape(Circle()),
                        doseAmnt: String(item.medDose ?? ""),
                        doseUnit: String(item.medUnit ?? ""),
                        title: String(item.medType ?? "")
                    )
                    .contextMenu() {
                        Button(
                            role: .destructive
                        ) {
                            trashItem(objectID: item.objectID)
                        } label: {
                            Label(NSLocalizedString("med.trash.item", comment: "tells user that action trashes medication"), systemImage: "trash")
                        }
                    }
                }
                PanelView(
                    icon:
                        Image("plus")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.accentColor)
                        .aspectRatio(1, contentMode: .fill)
                        .clipShape(Circle()),
                    doseAmnt: String(medsItems.count),
                    doseUnit: "",
                    title: String(format: NSLocalizedString("med.add.item", comment: "tells user that button adds item"))
                )
                .onTapGesture {
                    showAddMedSheet = true
                }
                .sheet(isPresented: $showAddMedSheet) {
                    if #available(iOS 16.0, *) {
                        AddMedsSheetView()
                            .presentationDetents([.medium, .large])
                    } else {
                        AddMedsSheetView()
                    }
                }
            }
        }
    }
}

struct MedsView_Previews: PreviewProvider {
    static var previews: some View {
        MedsView()
    }
}
