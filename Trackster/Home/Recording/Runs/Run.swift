//
//  StopwatchModel.swift
//  Trackster
//
//  Created by Rowby Villanueva on 9/11/26.
//

import Foundation
import SwiftData

@Model
nonisolated final class Run {
    #Index<Run>([\.startDate])
    
    var startDate:          Date
    var endDate:            Date
    var duration:           TimeInterval
    var distance:           Double?
    var averageHeartRate:   Double?
    var activeEnergy:       Double?
    var elevationGain:      Double?
    var maxElevation:       Double?
    var healthKitID:        UUID?   // nil = recorded in-app, set = imported from HealthKit

    @Relationship(deleteRule: .cascade, inverse: \RoutePoint.run)
    var route: [RoutePoint] = []
    
    init(startDate: Date, endDate: Date, duration: TimeInterval,
         distance: Double? = nil, averageHeartRate: Double? = nil,
         activeEnergy: Double? = nil, elevationGain: Double? = nil,
         maxElevation: Double? = nil, healthKitID: UUID? = nil) {
        self.startDate =    startDate
        self.endDate =      endDate
        self.duration =     duration
        self.distance =     distance
        self.averageHeartRate = averageHeartRate
        self.activeEnergy = activeEnergy
        self.elevationGain = elevationGain
        self.maxElevation = maxElevation
        self.healthKitID =  healthKitID
    }
}
