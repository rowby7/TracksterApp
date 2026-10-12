//
//  RunViewModel.swift
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
    private(set) var routeLocation: [CLLocation] = []
    
    private var locationTask: Task<Void, Never>?
    private var backgroundSession: CLBackgroundActivitySession?
    private var previousLocation: CLLocation?
    var showSaveErrorAlert = false
    
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
                    
                    routeLocation.append(location)
                    previousLocation = location
                    
                    print("String: \(totalDistance)")
                }
            } catch {
                print("Location error: \(error)")
            }
        }
    }
    

    
  private func elapsed(at date: Date) -> TimeInterval {
        guard let startDate else { return 0 }
        return date.timeIntervalSince(startDate)
    }
    
   private func formattedElapsed(at date: Date) -> String {
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
        let record = Run(startDate: startDate, endDate: .now, duration: elapsed(at: .now), distance: totalDistance)
        runContext.insert(record)
        
        record.route = routeLocation.map { location in
            RoutePoint(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                timestamp: location.timestamp,
                altitude: location.verticalAccuracy > 0 ? location.altitude : nil
            )
        }
        
        record.maxElevation = record.route.compactMap(\.altitude).max()
        record.elevationGain = elevationGain(of: routeLocation)
        
        do {
            try runContext.save()
        } catch {
            showSaveErrorAlert = true
        }
        
    }
    
    
    private func elevationGain(of locations: [CLLocation]) -> Double {
        var total = 0.0
        var previousAltitude: Double? = nil
        
        for location in locations {
            guard location.verticalAccuracy > 0 else { continue }
            
            if let previousAltitude, location.altitude > previousAltitude {
                     total += location.altitude - previousAltitude
                 }
            previousAltitude = location.altitude
        }
        
        return total
    }
    
    
    func pace(at date: Date) -> TimeInterval {
        
        guard totalDistance > 0 else { return 0 }
        
        let convertedDistance = totalDistance / 1609.344
        
        let pace = elapsed(at: date) / convertedDistance
        
        return pace
    }
    
    
}
