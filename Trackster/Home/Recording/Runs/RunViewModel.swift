//
//  StopwatchViewModel.swift
//  Trackster
//
//  Created by Rowby Villanueva on 9/11/26.
//

import Foundation
import SwiftData
import CoreLocation

@Observable
class RunViewModel {
    private(set) var startDate: Date?
    private(set) var isRunning = false
    private(set) var totalDistance: Double = 0
    
    private var locationTask: Task<Void, Never>?
    private var backgroundSession: CLBackgroundActivitySession?
    private var previousLocation: CLLocation?
    
    func start() {
                startDate = Date.now
                isRunning = true
        
        backgroundSession = CLBackgroundActivitySession()
        
        locationTask = Task {
            do {
                for try await update in CLLocationUpdate.liveUpdates(.fitness) {
                    guard let location = update.location,
                          (0...20).contains(location.horizontalAccuracy),
                          location.timestamp.timeIntervalSinceNow >= -5
                            else { continue }
                   
                    if let previousLocation {
                        totalDistance += location.distance(from: previousLocation)
                    }
                    
                    previousLocation = location
                    
                    print("String: \(totalDistance)")
                }
            } catch {
                print("Location error: \(error)")
            }
        }
    }
    
    
    func elapsed(at date: Date) -> TimeInterval {
        guard let startDate else { return 0 }
        return date.timeIntervalSince(startDate)
    }
    
    func formattedElapsed(at date: Date) -> String {
        let interval = elapsed(at: date)
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        let milliseconds = Int((interval.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d:%02d", minutes, seconds, milliseconds)
    }
    
    func stopAndSave(to runContext: ModelContext) {
        isRunning = false
        guard let startDate else { return }
        
        locationTask?.cancel()
        locationTask = nil
        
        backgroundSession?.invalidate()
        backgroundSession = nil
        let record = Run(startDate: startDate, endDate: .now, duration: elapsed(at: .now))
        runContext.insert(record)
    }
    
    
}
