//
//  RunDetailStat.swift
//  Trackster
//

import SwiftUI

/// One tile's worth of data on the run detail panel.
struct RunDetailStat: Identifiable {
    let title: String
    let value: String
    let systemImage: String
    let color: Color

    var id: String { title }
}
