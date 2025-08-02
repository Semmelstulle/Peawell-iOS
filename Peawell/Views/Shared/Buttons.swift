//
//  Buttons.swift
//  Peawell
//
//  Created by Dennis on 29.07.25.
//

import SwiftUI

struct AccessoryProminentButtonBig: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        if #available(iOS 26.0, *) {
            Button(action: action) {
                Label(title, systemImage: systemImage)
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
            }
            .padding()
            .buttonStyle(.glassProminent)
        } else {
            Button(action: action) {
                Label(title, systemImage: systemImage)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}

struct DismissToolbarButton: View {
    let action: () -> Void
    
    var body: some View {
        if #available(iOS 26.0, *) {
            Button {
                action()
            } label: {
                Image(systemName: "xmark")
            }
        } else {
            Button {
                action()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.gray)
                    .font(.system(size: 25))
                    .symbolRenderingMode(.hierarchical)
            }
        }
    }
}

struct DoneToolbarButton: View {
    let action: () -> Void
    
    var body: some View {
        if #available(iOS 26.0, *) {
            Button {
                action()
            } label: {
                Image(systemName: "checkmark")
            }
            .buttonStyle(.glassProminent)
        } else {
            Button {
                action()
            } label: {
                Image(systemName: "checkmark")
            }
        }
    }
}
