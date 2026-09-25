//
//  SampleData.swift
//  Trackster
//
//  Debug-only seeding so the simulator has something to render.
//

#if DEBUG
import Foundation
import SwiftData
import CoreLocation

enum SampleData {

    /// Inserts a handful of fake runs, but only when the store is empty.
    static func seedIfEmpty(_ container: ModelContainer) {
        let context = ModelContext(container)

        let existing = (try? context.fetchCount(FetchDescriptor<Run>())) ?? 0
        guard existing == 0 else { return }

        for run in makeRuns() {
            context.insert(run)
        }

        try? context.save()
    }

    private static func makeRuns() -> [Run] {
        // center, distance (m), duration (s), bpm, kcal, elevation gain (m)
        let recipes: [(CLLocationCoordinate2D, Double, TimeInterval, Double, Double, Double, Int)] = [
            (.init(latitude: 40.7580, longitude: -73.9855), 5230, 1684, 151, 342, 46, 1),
            (.init(latitude: 40.7291, longitude: -73.9965), 3180, 1042, 148, 208, 21, 4),
            (.init(latitude: 40.6782, longitude: -73.9442), 8120, 2610, 156, 531, 73, 8),
            (.init(latitude: 40.7812, longitude: -73.9665), 2870, 964, 143, 187, 16, 11),
            (.init(latitude: 40.7061, longitude: -74.0087), 6490, 2135, 153, 421, 58, 15)
        ]

        return recipes.map { center, distance, duration, bpm, kcal, gain, daysAgo in
            let start = Date.now.addingTimeInterval(-Double(daysAgo) * 86_400)
            let points = makeLoop(around: center, startingAt: start, duration: duration)

            let run = Run(
                startDate: start,
                endDate: start.addingTimeInterval(duration),
                duration: duration,
                distance: distance,
                averageHeartRate: bpm,
                activeEnergy: kcal,
                elevationGain: gain
            )

            run.route = points
            run.maxElevation = points.compactMap(\.altitude).max()
            return run
        }
    }

    /// A rough loop around a center point, so it reads as a route on a map.
    private static func makeLoop(
        around center: CLLocationCoordinate2D,
        startingAt start: Date,
        duration: TimeInterval,
        count: Int = 240
    ) -> [RoutePoint] {
        let radius = 0.008
        // A degree of longitude is narrower than a degree of latitude, so widen it
        // or the "loop" comes out as a squashed oval.
        let lonScale = 1 / cos(center.latitude * .pi / 180)

        return (0..<count).map { i in
            let progress = Double(i) / Double(count)
            let angle = progress * 2 * .pi
            let wobble = sin(angle * 6) * 0.0008

            return RoutePoint(
                latitude: center.latitude + (radius + wobble) * cos(angle),
                longitude: center.longitude + (radius + wobble) * sin(angle) * lonScale,
                timestamp: start.addingTimeInterval(progress * duration),
                altitude: 12 + sin(angle * 3) * 20
            )
        }
    }
}
#endif
