//
//  Split.swift
//  Trackster
//

import Foundation
import CoreLocation

nonisolated struct Split: Identifiable, Equatable {
    let number: Int
    let distance: Double
    let duration: TimeInterval

    var id: Int { number }

    var pace: TimeInterval {
        duration / (distance / Split.metersPerMile)
    }

    static let metersPerMile = 1609.344

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
