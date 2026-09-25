//
//  HKWorkout+Metrics.swift
//  Trackster
//
//  Created by Rowby Villanueva on 9/19/26.
//

import Foundation
import HealthKit

nonisolated extension HKWorkout {
    var distanceInMeters: Double? {
        statistics(for: HKQuantityType(.distanceWalkingRunning))?
            .sumQuantity()?
            .doubleValue(for: .meter())
    }

    var averageHeartRateInBPM: Double? {
        statistics(for: HKQuantityType(.heartRate))?
            .averageQuantity()?
            .doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
    }

    var activeEnergyInKilocalories: Double? {
        statistics(for: HKQuantityType(.activeEnergyBurned))?
            .sumQuantity()?
            .doubleValue(for: .kilocalorie())
    }

    var elevationGainInMeters: Double? {
        (metadata?[HKMetadataKeyElevationAscended] as? HKQuantity)?
            .doubleValue(for: .meter())
    }
}
