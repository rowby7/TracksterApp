//
//  RunDistanceHeroView.swift
//  Trackster
//

import SwiftUI

/// The run's distance, big, in the same orange as the route on the map.
struct RunDistanceHeroView: View {
    let run: Run

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            let number = Text(run.distanceNumberText)
                .font(.largeTitle.scaled(by: 2).bold())
                .foregroundStyle(.orange)
            let unit = Text(" mi")
                .font(.title.bold())
                .foregroundStyle(.secondary)

            Text("\(number)\(unit)")
                .fontDesign(.rounded)
                .monospacedDigit()

            Text("Distance")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Distance, \(run.distanceText)")
    }
}
