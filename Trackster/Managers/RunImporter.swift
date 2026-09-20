//
//  RunImporter.swift
//  Trackster
//

import Foundation
import HealthKit
import SwiftData
import CoreLocation

@ModelActor
actor RunImporter {
    private let healthKitManager = HealthKitManager()

    func importWorkouts() async throws {
        let workouts = try await healthKitManager.fetchWorkouts()

        let existingIDs = try modelContext.fetch(FetchDescriptor<Run>())
            .compactMap(\.healthKitID)
        let existingIDSet = Set(existingIDs)

        for workout in workouts where !existingIDSet.contains(workout.uuid) {
            let record = Run(
                startDate: workout.startDate,
                endDate: workout.endDate,
                duration: workout.duration,
                distance: workout.distanceInMeters,
                averageHeartRate: workout.averageHeartRateInBPM,
                activeEnergy: workout.activeEnergyInKilocalories,
                elevationGain: workout.elevationGainInMeters,
                healthKitID: workout.uuid
            )
            modelContext.insert(record)

            let locations = try await healthKitManager.routeLocations(for: workout)
            record.route = locations.map { location in
                RoutePoint(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    timestamp: location.timestamp,
                    altitude: location.verticalAccuracy > 0 ? location.altitude : nil
                )
            }

            record.maxElevation = record.route.compactMap(\.altitude).max()
        }

        try modelContext.save()
    }
}
