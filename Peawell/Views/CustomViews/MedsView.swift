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
    var tileTitle = "New"

    @State var showAddMedSheet = false

    var body: some View {
        ZStack {
            LazyVGrid(columns: [.init(), .init()]) {
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
                    title: tileTitle
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
                ForEach(medsItems) { item in
                    PanelView(
                        icon:
                            Image("pillLong")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.gray)
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
                            Label("Delete medication", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }
}

struct MedsView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
