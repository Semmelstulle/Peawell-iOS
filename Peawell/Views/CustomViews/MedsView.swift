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

    let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

    @State public var showAddMedSheet = false
    
    var body: some View {
        ZStack {
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
                        title: String(item.medType ?? ""),
                        reminder: (item.medRemind ? weekdays[Int(item.medDay)] + " " + (item.medTime?.formatted(date: .omitted, time: .shortened) ?? "") : "N/A")
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
                        Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Color.accentColor)
                        .clipShape(Circle()),
                    doseAmnt: String(medsItems.count),
                    doseUnit: "",
                    title: String(format: NSLocalizedString("med.add.item", comment: "tells user that button adds item")),
                    reminder: ""
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

struct PanelView<V: View>: View { var icon: V; var doseAmnt: String; var doseUnit: String; var title: String; var reminder: String;
    var body: some View {
        VStack {
            HStack(alignment: .top) {
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
                .frame(maxWidth: .infinity, alignment: .leading)
            /*Text(reminder)
                .font(.footnote)
                .foregroundColor(Color.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)*/
        }
        .padding()
        .background(Color.secondarySystemBackground)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

struct MedsView_Previews: PreviewProvider {
    static var previews: some View {
        MedsView()
    }
}
