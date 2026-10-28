//
//  WorkoutManager.swift
//  Trackster Watch Watch App
//
//  Created by Rowby Villanueva on 10/27/26.
//

import Foundation
import WatchKit
import HealthKit

@Observable
final class WorkoutManager {
    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    
    private(set) var isRunning = false
    
    func requestAuthorization() async throws {
        let workoutType = HKObjectType.workoutType()
        let routeType = HKSeriesType.workoutRoute()
        let heartRate = HKQuantityType(.heartRate)
        let distance = HKQuantityType(.distanceWalkingRunning)
        let energy = HKQuantityType(.activeEnergyBurned)
        try await healthStore.requestAuthorization(toShare: [workoutType, routeType, heartRate, distance, energy], read: [workoutType, routeType, heartRate, distance, energy])
    }
    
    func start() async throws {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = .outdoor
        
        let session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        let builder = session.associatedWorkoutBuilder()
        
        builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore,
        workoutConfiguration: configuration)
        
        self.session = session
        self.builder = builder
        
        let startDate = Date.now
        session.startActivity(with: startDate)
        try await builder.beginCollection(at: startDate)
           isRunning = true
    }
    
    func end() async throws {
        guard let session, let builder else { return }
        
        session.end()
        try await builder.endCollection(at: .now)
        try await builder.finishWorkout()
        
        isRunning = false
        self.session = nil
        self.builder = nil
    }
}
