//
//  CategoryChips.swift
//  Peawell
//
//  Created by Dennis on 28.07.25.
//

import SwiftUI

struct MoodCategory: Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    var sfsymbol: String?
    var isBuiltIn: Bool = false
}

struct ChipView: View {
    let category: MoodCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            if let symbol = category.sfsymbol {
                Image(systemName: symbol)
                    .foregroundColor(isSelected ? .white : .accentColor)
            }
            Text(category.name)
                .foregroundColor(isSelected ? .white : .primary)
                .font(.subheadline.weight(.medium))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(isSelected ? Color.accentColor : Color(.systemGray6))
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(isSelected ? Color.accentColor : Color(.systemGray3), lineWidth: 1)
        )
        .padding(4)
        .onTapGesture { onTap() }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct FlowLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        // Max width constrained by proposal or infinite
        let maxWidth = proposal.replacingUnspecifiedDimensions().width

        var currentRowWidth: CGFloat = 0
        var currentRowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var maxRowWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentRowWidth + size.width > maxWidth {
                // Next line
                totalHeight += currentRowHeight
                maxRowWidth = max(maxRowWidth, currentRowWidth)
                currentRowWidth = size.width
                currentRowHeight = size.height
            } else {
                currentRowWidth += size.width
                currentRowHeight = max(currentRowHeight, size.height)
            }
        }

        // Add last row
        totalHeight += currentRowHeight
        maxRowWidth = max(maxRowWidth, currentRowWidth)

        return CGSize(width: maxRowWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                // wrap to next line
                x = bounds.minX
                y += rowHeight
                rowHeight = 0
            }

            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width
            rowHeight = max(rowHeight, size.height)
        }
    }
}
