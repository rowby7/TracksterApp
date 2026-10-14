//
//  HealthKitManager.swift
//  Trackster
//
//  Created by Rowby Villanueva on 9/13/26.
//

import Foundation
import HealthKit
import CoreLocation

nonisolated final class HealthKitManager {
    private let healthStore = HKHealthStore()
    private let types: [HKWorkoutActivityType] = [.running, .walking]
    func requestAuthorization() async throws {
        let workoutType = HKObjectType.workoutType()
        let routeType = HKSeriesType.workoutRoute()
        try await healthStore.requestAuthorization(toShare: [], read: [workoutType, routeType])
    }
    
    func fetchWorkouts() async throws -> [HKWorkout] {
        let running = HKQuery.predicateForWorkouts(with: .running)
        let walking = HKQuery.predicateForWorkouts(with: .walking)
        let runningOrWalking = NSCompoundPredicate(orPredicateWithSubpredicates: [running, walking])

        let descriptor = HKSampleQueryDescriptor(
            predicates: [.workout(runningOrWalking)],
            sortDescriptors: [SortDescriptor(\.startDate, order: .reverse)]
        )
        return try await descriptor.result(for: healthStore)
    }
    
    func routeLocations(for workout: HKWorkout) async throws -> [CLLocation] {
        let predicate = HKQuery.predicateForObjects(from: workout)

        let routes: [HKWorkoutRoute] = try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: HKSeriesType.workoutRoute(),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: samples as? [HKWorkoutRoute] ?? [])
            }
            healthStore.execute(query)
        }

        guard let route = routes.first else { return [] }

        var locations: [CLLocation] = []
        for try await location in HKWorkoutRouteQueryDescriptor(route).results(for: healthStore) {
            locations.append(location)
        }
        return locations
    }
}


