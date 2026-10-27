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
        
        try await healthStore.requestAuthorization(toShare: [workoutType, routeType], read: [workoutType, routeType])
    }
    
}
