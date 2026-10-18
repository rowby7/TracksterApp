//
//  Split.swift
//  Trackster
//

import Foundation
import CoreLocation

/// One mile of a run, or the shorter leftover piece at the end.
// Pure math with no UI, so it can run anywhere — Run itself is nonisolated
nonisolated struct Split: Identifiable, Equatable {
    let number: Int
    let distance: Double        // meters: a full mile, except possibly the last split
    let duration: TimeInterval

    var id: Int { number }

    /// Seconds per mile, so a short final split still compares fairly with the full ones
    var pace: TimeInterval {
        duration / (distance / Split.metersPerMile)
    }

    static let metersPerMile = 1609.344

    /// Walks the route in time order and cuts it every mile. A mile usually ends partway
    /// between two GPS points, so the crossing time is estimated along that stretch.
    static func perMile(from points: [RoutePoint]) -> [Split] {
        let sorted = points.sorted { $0.timestamp < $1.timestamp }
        guard var previous = sorted.first else { return [] }

        var splits: [Split] = []
        var splitStartTime = previous.timestamp
        var distanceIntoSplit = 0.0

        for point in sorted.dropFirst() {
            var stretchDistance = location(of: previous).distance(from: location(of: point))
            var stretchStart = previous.timestamp
            var stretchDuration = point.timestamp.timeIntervalSince(previous.timestamp)

            // One long stretch between points can finish a mile, or even several
            while stretchDistance > 0, distanceIntoSplit + stretchDistance >= metersPerMile {
                let needed = metersPerMile - distanceIntoSplit
                let fraction = needed / stretchDistance
                let crossingTime = stretchStart.addingTimeInterval(stretchDuration * fraction)

                splits.append(Split(
                    number: splits.count + 1,
                    distance: metersPerMile,
                    duration: crossingTime.timeIntervalSince(splitStartTime)
                ))

                splitStartTime = crossingTime
                distanceIntoSplit = 0
                stretchDistance -= needed
                stretchDuration -= stretchDuration * fraction
                stretchStart = crossingTime
            }

            distanceIntoSplit += stretchDistance
            previous = point
        }

        // The leftover after the last full mile, ignoring GPS crumbs too small to mean anything
        if distanceIntoSplit > 10 {
            splits.append(Split(
                number: splits.count + 1,
                distance: distanceIntoSplit,
                duration: previous.timestamp.timeIntervalSince(splitStartTime)
            ))
        }

        return splits
    }

    private static func location(of point: RoutePoint) -> CLLocation {
        CLLocation(latitude: point.latitude, longitude: point.longitude)
    }
}
