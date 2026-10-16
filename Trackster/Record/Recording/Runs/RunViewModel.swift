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

    // MARK: - Run state

    private(set) var startDate: Date?
    private(set) var isRunning = false
    private(set) var totalDistance: Double = 0
    private(set) var routeLocation: [CLLocation] = []
    private(set) var accumulatedTime: TimeInterval = 0
    private(set) var segmentStart: Date? = nil
    private(set) var countdown: Int?
    private(set) var isGPSReady: Bool = false


    var showSaveErrorAlert = false
    var isPaused: Bool { isRunning && segmentStart == nil }
    var isCountingDown: Bool { countdown != nil }

    var phase: RunPhase {
        if isCountingDown { return .countingDown }
        if isPaused { return .paused }
        if isRunning { return .running }
        return .idle
    }

    // MARK: - Location plumbing

    private var locationTask: Task<Void, Never>?
    private var backgroundSession: CLBackgroundActivitySession?
    private var previousLocation: CLLocation?
    private var previewSession: CLServiceSession?
    private var previewTask: Task<Void, Never>?
    private var activeRun: Run?
    private var runContext: ModelContext?
    private var wantsPreviewLocation = false
    
    private var countdownTask: Task<Void, Never>?

    // MARK: - Recording

    func startCountdown(in runContext: ModelContext) {
        // A second tap mid-countdown must not stack another countdown on top
        guard countdownTask == nil else { return }

        countdownTask = Task {
            do {
                for number in stride(from: 3, through: 1, by: -1) {
                    countdown = number
                    try await Task.sleep(for: .seconds(1))
                }
                countdown = nil
                countdownTask = nil
                start(in: runContext)
            } catch {
                countdown = nil    // cancelled: back out without starting
                countdownTask = nil
            }
        }
    }

    func cancelCountdown() {
        countdownTask?.cancel()
    }

    func start(in runContext: ModelContext) {
        startDate = Date.now
        segmentStart = .now
        isRunning = true
        reset()

        let run = Run(startDate: .now, endDate: .now, duration: 0)
        run.isActive = true
        runContext.insert(run)
        try? runContext.save()
        
        activeRun = run
        self.runContext = runContext
        
        startLocationUpdates()
        
        saveClock()
    }

    func pause() {
        guard let segmentStart else { return }
        accumulatedTime += Date.now.timeIntervalSince(segmentStart)
        self.segmentStart = nil
        previousLocation = nil
        saveClock()
    }

    func resume() {
        guard segmentStart == nil else { return }
        segmentStart = .now
        saveClock()
    }

    
    func stopAndSave(to runContext: ModelContext) {
        isRunning = false
        guard let activeRun else { return }

        locationTask?.cancel()
        locationTask = nil

        backgroundSession?.invalidate()
        backgroundSession = nil

        activeRun.endDate = .now
        activeRun.duration = elapsed(at: .now)
        activeRun.distance = totalDistance
        activeRun.maxElevation = routeLocation
            .filter { $0.verticalAccuracy > 0 }
            .map(\.altitude)
            .max()
        activeRun.elevationGain = elevationGain(of: routeLocation)
        activeRun.isActive = false

        do {
            try runContext.save()
        } catch {
            showSaveErrorAlert = true
        }

        startDate = nil
        self.activeRun = nil
        self.runContext = nil
        reset()
        clearClock()
    }
    
    private func startLocationUpdates() {
        backgroundSession = CLBackgroundActivitySession()

        locationTask = Task {
            do {
                for try await update in CLLocationUpdate.liveUpdates(.fitness) {
                    guard let location = update.location else { continue }

                    isGPSReady = (0...20).contains(location.horizontalAccuracy)

                    guard (0...20).contains(location.horizontalAccuracy),
                          location.timestamp.timeIntervalSinceNow >= -5
                    else { continue }
                    
                    if let previousLocation {
                        totalDistance += location.distance(from: previousLocation)
                    }

                    routeLocation.append(location)
                    previousLocation = location

                    saveRoutePoint(location)
                    
                    print("String: \(totalDistance)")
                }
            } catch {
                print("Location error: \(error)")
            }
        }
    }

    func restoreActiveRun(in runContext: ModelContext) {
        guard !isRunning,
              let savedStart = UserDefaults.standard.object(forKey: "startDate") as? Date
        else { return }

        let descriptor = FetchDescriptor<Run>(predicate: #Predicate { run in run.isActive })
        guard let run = try? runContext.fetch(descriptor).first else {
            clearClock()
            return
        }

        activeRun = run
        
        restoreRoute(from: run)
        
        self.runContext = runContext
        startDate = savedStart
        segmentStart = UserDefaults.standard.object(forKey: "segmentStart") as? Date
        if segmentStart == nil {
            previousLocation = nil
        }
        accumulatedTime = UserDefaults.standard.double(forKey: "accumulatedTime")
        isRunning = true

        startLocationUpdates()
    }
    
    private func restoreRoute(from run: Run) {
        let points = run.route.sorted { $0.timestamp < $1.timestamp }

        for point in points {
            let location = CLLocation(
                coordinate: CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude),
                altitude: point.altitude ?? 0,
                horizontalAccuracy: 5,
                verticalAccuracy: point.altitude == nil ? -1 : 1,
                timestamp: point.timestamp
            )

            if let previousLocation {
                totalDistance += location.distance(from: previousLocation)
            }

            routeLocation.append(location)
            previousLocation = location
        }
    }
    
    private func saveRoutePoint(_ location: CLLocation) {
        guard let activeRun, let runContext else { return }

        let point = RoutePoint(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            timestamp: location.timestamp,
            altitude: location.verticalAccuracy > 0 ? location.altitude : nil,
            run: activeRun
        )
        runContext.insert(point)

        if routeLocation.count.isMultiple(of: 10) {
            try? runContext.save()
        }
    }
    
    // MARK: - Live stats

    func formattedElapsed(at date: Date) -> String {
        let interval = elapsed(at: date)
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        let milliseconds = Int((interval.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d:%02d", minutes, seconds, milliseconds)
    }

    func pace(at date: Date) -> TimeInterval {
        guard totalDistance > 0 else { return 0 }

        let convertedDistance = totalDistance / 1609.344

        let pace = elapsed(at: date) / convertedDistance

        return pace
    }

    private func elapsed(at date: Date) -> TimeInterval {
        if let segmentStart {
            return accumulatedTime + date.timeIntervalSince(segmentStart)
        }
        return accumulatedTime
    }

    // MARK: - Preview location (the map before and between runs)

    func startPreviewLocation() {
        wantsPreviewLocation = true
        openPreviewSession()
    }

    func stopPreviewLocation() {
        wantsPreviewLocation = false
        closePreviewSession()
    }

    func suspendPreviewLocation() {
        guard !isRunning else { return }
        closePreviewSession()
    }

    func resumePreviewLocation() {
        guard wantsPreviewLocation else { return }
        openPreviewSession()
    }

    private func openPreviewSession() {
        guard previewSession == nil else { return }
        // Asks for When In Use permission the first time
        previewSession = CLServiceSession(authorization: .whenInUse)

        // Watches signal quality while the map is up, so Start can wait for a good fix
        previewTask = Task {
            do {
                for try await update in CLLocationUpdate.liveUpdates(.fitness) {
                    guard let location = update.location else { continue }
                    isGPSReady = (0...20).contains(location.horizontalAccuracy)
                }
            } catch {}
        }
    }

    private func closePreviewSession() {
        previewTask?.cancel()
        previewTask = nil
        previewSession?.invalidate()
        previewSession = nil

        // Nothing is checking the signal now, so don't claim it's still good
        if !isRunning {
            isGPSReady = false
        }
    }

    // MARK: - Crash recovery

    private func saveClock() {
        UserDefaults.standard.set(startDate, forKey: "startDate")
        UserDefaults.standard.set(segmentStart, forKey: "segmentStart")
        UserDefaults.standard.set(accumulatedTime, forKey: "accumulatedTime")
    }

    private func clearClock() {
        UserDefaults.standard.removeObject(forKey: "startDate")
        UserDefaults.standard.removeObject(forKey: "segmentStart")
        UserDefaults.standard.removeObject(forKey: "accumulatedTime")

    }
    // MARK: - Helpers

    private func reset() {
        accumulatedTime = 0
        totalDistance = 0
        routeLocation = []
        previousLocation = nil
    }

    private func elevationGain(of locations: [CLLocation]) -> Double {
        let threshold = 5.0
        var total = 0.0
        var anchorAltitude: Double? = nil

        for location in locations {
            guard location.verticalAccuracy > 0 else { continue }

            guard let anchor = anchorAltitude else {
                anchorAltitude = location.altitude
                continue
            }

            if location.altitude - anchor >= threshold {
                total += location.altitude - anchor
                anchorAltitude = location.altitude
            } else if anchor - location.altitude >= threshold {
                anchorAltitude = location.altitude
            }
        }

        return total
    }
}
