//
//  MedDetailsView.swift
//  Peawell
//
//  Created by Dennis on 17.04.23.
//

import SwiftUI

struct MedDetailsView: View { var detailTitle: Text
    var body: some View {
        ScrollView() {
            detailTitle
                .font(.title)
        }.padding()
    }
}

struct MedDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
