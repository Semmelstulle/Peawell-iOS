//
//  MedLogView.swift
//  Peawell
//
//  Created by dennis on 14.06.24.
//

import SwiftUI

struct MedLogView: View {

    //  adds fetched data to scope
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Meds.medType, ascending: true)], animation: .default)
    var medsItems: FetchedResults<Meds>

    var body: some View {
        List {
            Section(header: Text(NSLocalizedString("meds section", comment: "tell the person this is the section containing their logged medication"))) {
                ForEach(medsItems) { item in
                    HStack() {
                        Image(item.medKind ?? "")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(6)
                            .background(Color.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        Text(item.medType ?? "")
                        Spacer()
                        Text(item.medDose ?? "")
                            .opacity(0.4)
                        Text(item.medUnit ?? "")
                            .opacity(0.4)
                    }
                    .swipeActions(allowsFullSwipe: true) {
                        Button(
                            role: .destructive
                        ) {
                            trashItem(objectID: item.objectID)
                        } label: {
                            Label(NSLocalizedString("delete diary", comment: "tell the person this button deletes the diary"), systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Overview")
    }
}

#Preview {
    MedLogView()
}
