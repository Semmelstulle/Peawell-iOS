//
//  GlobalValues.swift
//  Peawell
//
//  Created by Dennis on 14.06.25.
//

import SwiftUI

struct Constants {
    static var cornerRadiusPrimary: CGFloat {
        if #available(iOS 26.0, *) {
            return 24
        } else {
            return 12
        }
    }
    static var cornerRadiusSecondary: CGFloat {
        if #available(iOS 26.0, *) {
            return 16
        } else {
            return 8
        }
    }
    static var localizedWeekdaySymbols: [String] {
        let calendar = Calendar.current
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let firstWeekday = calendar.firstWeekday // 1 = Sunday, 2 = Monday, ...
        let reordered = Array(symbols[firstWeekday-1..<symbols.count] + symbols[0..<firstWeekday-1])
        return reordered
    }
}
