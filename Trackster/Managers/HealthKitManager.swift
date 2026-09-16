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
        try await healthStore.requestAuthorization(toShare: [], read: [workoutType])
    }
    
    func fetchWorkouts() async throws -> [HKWorkout] {
           let workoutType = HKObjectType.workoutType()

           return try await withCheckedThrowingContinuation { continuation in
               let query = HKSampleQuery(
                   sampleType: workoutType,
                   predicate: nil,
                   limit: HKObjectQueryNoLimit,
                   sortDescriptors: nil
               ) { _, samples, error in
                   if let error {
                       continuation.resume(throwing: error)
                       return
                   }
                   let workouts = samples as? [HKWorkout] ?? []
                   continuation.resume(returning: workouts)
               }
               healthStore.execute(query)
           }
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
                  healthKitID: workout.uuid
              )
              runContext.insert(record)
          }

          try runContext.save()
      }
}
