//
//  GlobalValues.swift
//  Peawell
//
//  Created by Dennis on 14.06.25.
//

import SwiftUI

struct Constants {
    static var cornerRadiusPrimary: CGFloat {
        if #available(iOS 26, *) {
            return 24
        } else {
            return 12
        }
    }
    static var cornerRadiusSecondary: CGFloat {
        if #available(iOS 26, *) {
            return 16
        } else {
            return 8
        }
    }
}
