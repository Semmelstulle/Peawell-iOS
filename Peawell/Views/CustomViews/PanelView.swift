//
//  PanelView.swift
//  Peawell
//
//  Created by Dennis on 16.04.23.
//

import SwiftUI

//  the whole view is the medication cell part
struct PanelView<V: View>: View { var icon: V; var doseAmnt: String; var doseUnit: String; var title: String
    var body: some View {
        VStack {
            HStack {
                Text(doseAmnt)
                    .font(.title3)
                    .foregroundColor(Color.secondary)
                Text(doseUnit)
                    .font(.title3)
                    .foregroundColor(Color.secondary)
                Spacer()
                icon
            }
            Text(title)
                .font(.title3)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.secondarySystemBackground)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

struct PanelView_Previews: PreviewProvider {
    static var previews: some View {
        // the panels itself aren't as interesting, so we preview the whole main page
        MainView()
    }
}
