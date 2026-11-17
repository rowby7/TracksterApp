//
//  WorkoutManager.swift
//  Trackster Watch Watch App
//
//  Created by Rowby Villanueva on 10/27/26.
//

import Foundation
import WatchKit
import HealthKit
import CoreLocation

@Observable
final class WorkoutManager: NSObject, HKLiveWorkoutBuilderDelegate, HKWorkoutSessionDelegate {
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        _ = Task { @MainActor in
            isPaused = toState == .paused
        }
    }
    
   nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: any Error) {
       print("Workout session failed: \(error)")
   }
    

    // MARK: - Workout state

    private(set) var isRunning = false
    private(set) var isPaused = false
    private(set) var heartRate: Double = 0
    private(set) var distance: Double = 0
    private(set) var calories: Double = 0
    private var locationSession: CLServiceSession?
    private var locationTask: Task<Void, Never>?
    var elapsedTime: TimeInterval {
        builder?.elapsedTime ?? 0
    }
    var pace: Double {
        guard miles > 0 else { return 0 }
        return elapsedTime / miles
    }
    
    var miles: Double {
        return distance/1609.344
    }

    // MARK: - HealthKit plumbing

    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    // MARK: - Permission

    func requestAuthorization() async throws {
        let workoutType = HKObjectType.workoutType()
        let routeType = HKSeriesType.workoutRoute()
        let heartRate = HKQuantityType(.heartRate)
        let distance = HKQuantityType(.distanceWalkingRunning)
        let energy = HKQuantityType(.activeEnergyBurned)
        try await healthStore.requestAuthorization(toShare: [workoutType, routeType, heartRate, distance, energy], read: [workoutType, routeType, heartRate, distance, energy])
    }

    func requestLocationAuthorization() {
        guard locationSession == nil else { return }

        locationSession = CLServiceSession(authorization: .whenInUse)
     
    }
    
    func startLocationUpdates() {
        locationTask = Task {
            do {
                for try await update in CLLocationUpdate.liveUpdates(.fitness) {
                    guard let location = update.location else { continue }
                    print("GPS: \(location.coordinate)")
                }
            } catch {
                
            }
        }
    }
    
    func endLocationUpdates() {
        locationTask?.cancel()
        locationTask = nil
        locationSession?.invalidate()
        locationSession = nil
    }
    
    // MARK: - Start and stop

    func start() async throws {
        
        guard session == nil else { return }
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = .outdoor

        let session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        let builder = session.associatedWorkoutBuilder()

        builder.delegate = self
        builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore,
                                                     workoutConfiguration: configuration)
        session.delegate = self
        self.session = session
        self.builder = builder

        let startDate = Date.now
        session.startActivity(with: startDate)
        try await builder.beginCollection(at: startDate)
        
        startLocationUpdates()

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
        endLocationUpdates()
        reset()
    }
    
    func pause() {
        session?.pause()
    }
    
    func resume() {
        session?.resume()
    }
    
    private func reset() {
        heartRate = 0
        distance = 0
        calories = 0
    }

    // MARK: - Builder delegate (HealthKit calls these, from a background thread)

    nonisolated func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        
        
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { continue }
            let statistics = workoutBuilder.statistics(for: quantityType)
            _ = Task { @MainActor in
                update(from: statistics)
            }
        }
    }
    
    private func update(from statistics: HKStatistics?) {
        guard let statistics else { return }
        
        switch statistics.quantityType {
        case HKQuantityType(.heartRate):
            heartRate = statistics.mostRecentQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) ?? 0
            
        case HKQuantityType(.distanceWalkingRunning):
            distance = statistics.sumQuantity()?.doubleValue(for: HKUnit.meter()) ?? 0.0
            
        case HKQuantityType(.activeEnergyBurned):
            calories = statistics.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0.0
        default:
            break
        }
    }

    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        return
    }


}
