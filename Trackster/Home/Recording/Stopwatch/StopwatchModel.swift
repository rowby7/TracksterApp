//
//  StopwatchModel.swift
//  Trackster
//
//  Created by Rowby Villanueva on 9/11/26.
//

import Foundation
import SwiftData

@Model
final class StopwatchModel {
    var startDate: Date
    var endDate: Date
    var duration: TimeInterval

    init(startDate: Date, endDate: Date, duration: TimeInterval) {
        self.startDate = startDate
        self.endDate = endDate
        self.duration = duration
    }
}
