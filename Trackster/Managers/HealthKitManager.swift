//
//  HealthKitManager.swift
//  Trackster
//
//  Created by Rowby Villanueva on 9/13/26.
//

import Foundation
import HealthKit
import SwiftData

@Observable
class HealthKitManager {
    private let healthStore = HKHealthStore()

    func requestAuthorization() async throws {
        let workoutType = HKObjectType.workoutType()
        let routeType = HKSeriesType.workoutRoute()
        try await healthStore.requestAuthorization(toShare: [], read: [workoutType, routeType])
    }
    
    func fetchWorkouts() async throws -> [HKWorkout] {
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.workout()],
            sortDescriptors: [SortDescriptor(\.startDate, order: .reverse)]
        )
        return try await descriptor.result(for: healthStore)
    }
    
    
    func importWorkouts(into runContext: ModelContext) async throws {
          let workouts = try await fetchWorkouts()
          let existingIDs = try runContext.fetch(FetchDescriptor<Run>())
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
              runContext.insert(record)
          }

          try runContext.save()
      }
}


extension HKWorkout {
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
