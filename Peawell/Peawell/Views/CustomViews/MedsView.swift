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
                    title: "Medications"
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
                        NavigationLink(
                            destination: EditMedsView().navigationTitle(String(item.medType ?? ""))
                        ) {
                            Button() {
                            } label: {
                                Label("Edit medication", systemImage: "pencil")
                            }
                        }
                        Button(role: .destructive) {
                            trashMeds(objectID: item.objectID)
                        } label: {
                            Label("Delete medication", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }

/*
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Mood.moodName, ascending: true)], animation: .default)
    var items: FetchedResults<Mood>

    //  these define the user input field's empty state
    @State var medName: String = ""
    @State var medAmount: String = ""

    var body: some View {
        NavigationView() {
            Form() {
                TextField(
                    text: $medName,
                    prompt: Text("What is your medication called?")
                ) {
                    Text("Activity name")
                }
                .padding()
                TextField(
                    text: $medAmount,
                    prompt: Text("Dose here")
                ) {
                    Text("Your mood")
                }
                .padding()
                Button(
                    action: {
                        saveMeds(medName: medName, medAmount: medAmount)
                    }, label: {
                        Label("Add medication", systemImage: "plus")
                    }
                )
            }
            .navigationTitle(medsSheetTitle)
        }
    }*/
}

struct MedsView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
