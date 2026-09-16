//
//  StopwatchModel.swift
//  Trackster
//
//  Created by Rowby Villanueva on 9/11/26.
//

import Foundation
import SwiftData

@Model
final class Run {
    var startDate: Date
    var endDate: Date
    var duration: TimeInterval
    var healthKitID: UUID?   // nil = recorded in-app, set = imported from HealthKit

    init(startDate: Date, endDate: Date, duration: TimeInterval, healthKitID: UUID? = nil) {
        self.startDate = startDate
        self.endDate = endDate
        self.duration = duration
        self.healthKitID = healthKitID
    }
}
