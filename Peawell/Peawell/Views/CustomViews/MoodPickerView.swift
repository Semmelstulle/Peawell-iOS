//
//  MoodPickerView.swift
//  Peawell
//
//  Created by Dennis on 17.04.23.
//

import SwiftUI

struct MoodPickerView: View {
    var body: some View {
        HStack() {
            Image(systemName: "person.fill")
                .padding()
                .background(.green)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }.padding()
    }
}

struct MoodPickerView_Previews: PreviewProvider {
    static var previews: some View {
        MoodPickerView()
    }
}
