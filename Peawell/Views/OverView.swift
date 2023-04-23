//
//  AddActivityView.swift
//  Peawell
//
//  Created by Dennis on 12.04.23.
//

import SwiftUI

struct OverView: View {
    
    //  adds fetched data to scope
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Mood.logDate, ascending: true)], animation: .default)
    var moodItems: FetchedResults<Mood>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Meds.medType, ascending: true)], animation: .default)
    var medsItems: FetchedResults<Meds>
    
    var body: some View {
        NavigationView() {
            Form() {
                Section(header: Text("Mood log")) {
                    ForEach(moodItems) { item in
                        HStack() {
                            Text(item.moodName ?? "Error")
                            Text(" - ")
                            Text(item.activityName ?? "Error")
                        }
                    }
                }
                Section(header: Text("Medication log")) {
                    ForEach(medsItems) { item in
                        HStack() {
                            Text(item.medType ?? "")
                            Text(" - ")
                            Text(item.medDose ?? "")
                            Text(item.medUnit ?? "")
                            Text(item.medKind ?? "")
                        }
                    }
                }
            }.navigationTitle("Overview")
        }
    }
}

struct AddActivityView_Previews: PreviewProvider {
    static var previews: some View {
        OverView()
    }
}
