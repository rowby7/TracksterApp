//
//  MockData.swift
//  Trackster
//
//  Sample runs for screenshots and demos. Debug builds only: launch with the `-mockData`
//  argument and the app uses a throwaway in-memory database filled with these instead of
//  your real runs, and skips the HealthKit import.
//

#if DEBUG
import Foundation
import SwiftData
import CoreLocation

enum MockData {

    static var isEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains("-mockData")
    }

    static func seed(into context: ModelContext) {
        for template in templates {
            let points = route(for: template)
            let locations = points.map(\.location)

            let distance = zip(locations, locations.dropFirst())
                .reduce(0) { $0 + $1.1.distance(from: $1.0) }
            let duration = points.last!.timestamp.timeIntervalSince(points.first!.timestamp)

            let run = Run(
                startDate: template.start,
                endDate: template.start.addingTimeInterval(duration),
                duration: duration,
                distance: distance,
                averageHeartRate: template.heartRate,
                activeEnergy: template.calories,
                elevationGain: elevationGain(of: points.map(\.altitude)),
                maxElevation: points.map(\.altitude).max(),
                healthKitID: template.isFromWatch ? UUID() : nil
            )
            context.insert(run)

            for point in points {
                context.insert(RoutePoint(
                    latitude: point.location.coordinate.latitude,
                    longitude: point.location.coordinate.longitude,
                    timestamp: point.timestamp,
                    altitude: point.altitude,
                    run: run
                ))
            }
        }
        try? context.save()
    }

    // MARK: - The runs

    private struct Template {
        let waypoints: [CLLocationCoordinate2D]
        let laps: Int
        let outAndBack: Bool
        let secondsPerMile: Double
        let daysAgo: Int
        let hour: Int
        let heartRate: Double?
        let calories: Double?
        let altitude: (CLLocationCoordinate2D, Double) -> Double   // (position, progress 0–1)

        var isFromWatch: Bool { heartRate != nil }

        var start: Date {
            let day = Calendar.current.date(byAdding: .day, value: -daysAgo, to: .now)!
            return Calendar.current.date(bySettingHour: hour, minute: 12, second: 0, of: day)!
        }
    }

    private static let centralParkLoop = [
        c(40.7690, -73.9800), c(40.7760, -73.9752), c(40.7832, -73.9690), c(40.7905, -73.9648),
        c(40.7975, -73.9600), c(40.7962, -73.9562), c(40.7935, -73.9535), c(40.7865, -73.9590),
        c(40.7797, -73.9650), c(40.7728, -73.9700), c(40.7660, -73.9745), c(40.7690, -73.9800)
    ]

    private static let reservoir: [CLLocationCoordinate2D] = (0...24).map { step in
        let angle = Double(step) / 24 * 2 * .pi
        return c(40.7852 + 0.0036 * sin(angle), -73.9625 + 0.0048 * cos(angle))
    }

    private static let hudsonGreenway = [
        c(40.7095, -74.0170), c(40.7160, -74.0160), c(40.7230, -74.0128),
        c(40.7300, -74.0112), c(40.7370, -74.0102), c(40.7440, -74.0090), c(40.7480, -74.0085)
    ]

    private static let brooklynBridge = [
        c(40.7120, -74.0045), c(40.7090, -74.0008), c(40.7058, -73.9967),
        c(40.7035, -73.9932), c(40.7020, -73.9900)
    ]

    private static let templates: [Template] = [
        Template(waypoints: brooklynBridge, laps: 1, outAndBack: true, secondsPerMile: 545,
                 daysAgo: 1, hour: 7, heartRate: nil, calories: nil,
                 altitude: { _, progress in 6 + 38 * sin(progress * .pi) }),
        Template(waypoints: centralParkLoop, laps: 1, outAndBack: false, secondsPerMile: 532,
                 daysAgo: 3, hour: 6, heartRate: 156, calories: 588,
                 altitude: { position, _ in 22 + (position.latitude - 40.766) / 0.031 * 30 }),
        Template(waypoints: reservoir, laps: 2, outAndBack: false, secondsPerMile: 560,
                 daysAgo: 5, hour: 6, heartRate: 148, calories: 331,
                 altitude: { _, progress in 32 + 7 * sin(progress * 4 * .pi) }),
        Template(waypoints: hudsonGreenway, laps: 1, outAndBack: true, secondsPerMile: 550,
                 daysAgo: 8, hour: 7, heartRate: nil, calories: nil,
                 altitude: { _, progress in 6 + 9 * sin(progress * 2 * .pi) }),
        Template(waypoints: reservoir, laps: 1, outAndBack: false, secondsPerMile: 1_050,
                 daysAgo: 10, hour: 18, heartRate: 104, calories: 118,
                 altitude: { _, progress in 32 + 7 * sin(progress * 2 * .pi) }),
        Template(waypoints: centralParkLoop, laps: 1, outAndBack: false, secondsPerMile: 555,
                 daysAgo: 12, hour: 6, heartRate: 151, calories: 574,
                 altitude: { position, _ in 22 + (position.latitude - 40.766) / 0.031 * 30 })
    ]

    // MARK: - Building a route

    private struct Point {
        let location: CLLocation
        let timestamp: Date
        let altitude: Double
    }

    /// Walks along the waypoints at the template's pace, dropping a point every 2 seconds
    private static func route(for template: Template) -> [Point] {
        var path = Array(repeating: template.waypoints, count: template.laps).flatMap { $0 }
        if template.outAndBack {
            path += template.waypoints.reversed().dropFirst()
        }

        let metersPerSecond = 1609.344 / template.secondsPerMile
        let secondsPerPoint = 2.0

        let legs = zip(path, path.dropFirst()).map { start, end in
            (start, end, CLLocation(latitude: start.latitude, longitude: start.longitude)
                .distance(from: CLLocation(latitude: end.latitude, longitude: end.longitude)))
        }
        let totalMeters = legs.reduce(0) { $0 + $1.2 }

        var points: [Point] = []
        var covered = 0.0
        var elapsed = 0.0

        while covered < totalMeters {
            // Find which leg this distance falls on, then how far along it
            var remaining = covered
            var position = path[0]
            for (start, end, length) in legs {
                if remaining <= length {
                    let t = length > 0 ? remaining / length : 0
                    position = c(start.latitude + (end.latitude - start.latitude) * t,
                                 start.longitude + (end.longitude - start.longitude) * t)
                    break
                }
                remaining -= length
            }

            // A little GPS wobble so the line doesn't look ruler-straight
            let jittered = c(position.latitude + Double.random(in: -0.000012...0.000012),
                             position.longitude + Double.random(in: -0.000012...0.000012))
            let progress = covered / totalMeters

            points.append(Point(
                location: CLLocation(latitude: jittered.latitude, longitude: jittered.longitude),
                timestamp: template.start.addingTimeInterval(elapsed),
                altitude: template.altitude(position, progress) + Double.random(in: -0.4...0.4)
            ))

            // Pace drifts a bit over the run, like a real one
            let drift = 1 + 0.06 * sin(elapsed / 240)
            covered += metersPerSecond * drift * secondsPerPoint
            elapsed += secondsPerPoint
        }

        return points
    }

    /// Same 5 m threshold idea as the live recording, so mock numbers look like real ones
    private static func elevationGain(of altitudes: [Double]) -> Double {
        guard var anchor = altitudes.first else { return 0 }
        var total = 0.0
        for altitude in altitudes.dropFirst() {
            if altitude - anchor >= 5 {
                total += altitude - anchor
                anchor = altitude
            } else if anchor - altitude >= 5 {
                anchor = altitude
            }
        }
        return total
    }

    private static func c(_ latitude: Double, _ longitude: Double) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
#endif
