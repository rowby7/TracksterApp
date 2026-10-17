//
//  TracksterTests.swift
//  TracksterTests
//
//  Created by Rowby Villanueva on 9/10/26.
//

import Testing
import CoreLocation
@testable import Trackster

// RunViewModel lives on the main actor, so its tests run there too
@MainActor
struct TracksterTests {

    // MARK: - A brand-new run

    @Test func newRunStartsAtZero() {
        // Arrange
        let viewModel = RunViewModel()

        // Act
        let text = viewModel.formattedElapsed(at: .now)

        // Assert
        #expect(text == "00:00:00")
    }

    @Test func newRunIsIdle() {
        let viewModel = RunViewModel()

        #expect(viewModel.phase == .idle)
    }

    // MARK: - Elevation gain

    @Test func steadyClimbCountsTheClimb() {
        let viewModel = RunViewModel()
        let climb = locations(altitudes: [100, 105, 110, 115, 120])

        let gain = viewModel.elevationGain(of: climb)

        #expect(gain == 20)
    }

    @Test func gpsWobbleOnFlatGroundIsIgnored() {
        let viewModel = RunViewModel()
        // Standing still, but GPS altitude bounces a few meters
        let flat = locations(altitudes: [100, 103, 99, 102, 98, 101])

        let gain = viewModel.elevationGain(of: flat)

        #expect(gain == 0)
    }

    @Test func downhillDoesNotCount() {
        let viewModel = RunViewModel()
        let descent = locations(altitudes: [120, 110, 100])

        let gain = viewModel.elevationGain(of: descent)

        #expect(gain == 0)
    }

    @Test func badAltitudeReadingsAreSkipped() {
        let viewModel = RunViewModel()
        // The 500 m spike has an invalid vertical accuracy, so it must not count
        let route = [
            location(altitude: 100),
            location(altitude: 500, verticalAccuracy: -1),
            location(altitude: 110)
        ]

        let gain = viewModel.elevationGain(of: route)

        #expect(gain == 10)
    }

    // MARK: - Helpers

    private func location(altitude: Double, verticalAccuracy: Double = 3) -> CLLocation {
        CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 40.0, longitude: -74.0),
            altitude: altitude,
            horizontalAccuracy: 5,
            verticalAccuracy: verticalAccuracy,
            timestamp: .now
        )
    }

    private func locations(altitudes: [Double]) -> [CLLocation] {
        altitudes.map { location(altitude: $0) }
    }
}
