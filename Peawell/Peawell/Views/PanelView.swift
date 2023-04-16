//
//  PanelView.swift
//  Peawell
//
//  Created by Dennis on 16.04.23.
//

import SwiftUI

extension Color {
    static let secondarySystemBackground =
        Color(uiColor: .secondarySystemBackground)
    static let systemFill =
        Color(uiColor: .systemGray)
}

struct PanelView<V: View>: View { var icon: V; var bundle: Int; var title: LocalizedStringKey
    var body: some View {
        VStack {
            HStack {
                icon
                Spacer()
                Text(bundle, format: .number)
                    .font(.title)
            }
            Text(title)
                .font(.title3)
                .foregroundColor(Color.systemFill)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.secondarySystemBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct PanelView_Previews: PreviewProvider {
    static var previews: some View {
        //PanelView()
        MainView()
    }
}
