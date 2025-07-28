//
//  ToolbarItems.swift
//  Peawell
/*/
//  Created by Dennis on 28.07.25.
//

import SwiftUI

@Environment(\.dismiss) private var dismiss

func dismissButton() -> some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
        if #available(iOS 26.0, *) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
            }
        } else {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.gray)
                    .font(.system(size: 25))
                    .symbolRenderingMode(.hierarchical)
            }
        }
    }
}
*/
