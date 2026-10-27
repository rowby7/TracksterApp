//
//  RunDetailViewModel.swift
//  Trackster
//
//  Created by Rowby Villanueva on 10/17/26.
//

import Foundation
import MapKit
import CoreLocation

@Observable
class RunDetailViewModel {
    let run: Run
    private(set) var coordinates: [CLLocationCoordinate2D] = []
    private(set) var drawnPosition: Double = 0
    private(set) var splits: [Split] = []

    var isDrawingFinished: Bool {
        !coordinates.isEmpty && drawnPosition >= Double(coordinates.count - 1)
    }
    
    var visibleCoordinates: [CLLocationCoordinate2D] {
        guard !coordinates.isEmpty else { return [] }

        let lastFullPoint = min(Int(drawnPosition), coordinates.count - 1)
        var visible = Array(coordinates[0...lastFullPoint])

        let fraction = drawnPosition - Double(lastFullPoint)
        if fraction > 0, lastFullPoint + 1 < coordinates.count {
            let from = coordinates[lastFullPoint]
            let to = coordinates[lastFullPoint + 1]
            visible.append(CLLocationCoordinate2D(
                latitude: from.latitude + (to.latitude - from.latitude) * fraction,
                longitude: from.longitude + (to.longitude - from.longitude) * fraction
            ))
        }

        return visible
    }

    /// The tip of the line, where the runner dot sits. Worked out directly rather than through
    /// visibleCoordinates, because this runs every frame and that builds a whole array.
    var runnerCoordinate: CLLocationCoordinate2D? {
        guard !coordinates.isEmpty else { return nil }

        let lastFullPoint = min(Int(drawnPosition), coordinates.count - 1)
        let fraction = drawnPosition - Double(lastFullPoint)
        guard fraction > 0, lastFullPoint + 1 < coordinates.count else {
            return coordinates[lastFullPoint]
        }

        let from = coordinates[lastFullPoint]
        let to = coordinates[lastFullPoint + 1]
        return CLLocationCoordinate2D(
            latitude: from.latitude + (to.latitude - from.latitude) * fraction,
            longitude: from.longitude + (to.longitude - from.longitude) * fraction
        )
    }

    init(run: Run) {
        self.run = run
    }

    func loadRoute() {
        coordinates = run.route
            .sorted { $0.timestamp < $1.timestamp }
            .map { point in
                CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
            }
        // Splits walk the whole route too, so work them out once here instead of in a view's body
        splits = run.splits
    }

    /// Reveals the route a little at a time so it looks drawn in, taking `duration` seconds
    /// however long the run was. Runs inside the view's `.task`, so leaving the screen cancels it.
    func drawRoute(over duration: Double = 6, animated: Bool) async {
        guard animated, !coordinates.isEmpty else {
            drawnPosition = Double(coordinates.count - 1)
            return
        }

        let framesPerSecond = 60.0
        let totalFrames = Int(duration * framesPerSecond)

        for frame in 1...totalFrames {
            drawnPosition = Double(coordinates.count - 1) * Double(frame) / Double(totalFrames)
            try? await Task.sleep(for: .seconds(1 / framesPerSecond))
            if Task.isCancelled { return }
        }
        drawnPosition = Double(coordinates.count - 1)
    }
}
