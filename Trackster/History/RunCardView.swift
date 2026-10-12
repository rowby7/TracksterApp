//
//  RunCardView.swift
//  Trackster
//
//  Created by Rowby Villanueva on 9/11/26.
//

import SwiftUI
import SwiftData

struct RunCardView: View {
    let run: Run

    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(run.startDate, format: .dateTime.day().month().year())
                        .font(.subheadline)
                        .opacity(0.6)

                    HStack(spacing: 20) {
                        StatColumnView(title: "Distance", value: distanceText)
                        StatColumnView(title: "Avg. BPM", value: bpmText)
                        StatColumnView(title: "Elevation Gain", value: elevationGainText)
                    }

                    Text(Duration.seconds(run.duration), format: .time(pattern: .minuteSecond))
                        .font(.largeTitle.bold())
                }

                Spacer()

                Image(systemName: "figure.run")
                    .font(.title)
            }

            RouteSnapshotView(points: run.route, id: run.persistentModelID)
        }
    }

    private var distanceText: String {
        guard let distance = run.distance else { return "--" }
        return Measurement(value: distance, unit: UnitLength.meters)
            .converted(to: .miles)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(2))))
    }

    private var bpmText: String {
        guard let bpm = run.averageHeartRate else { return "--" }
        return "\(Int(bpm.rounded())) bpm"
    }

    private var elevationGainText: String {
        guard let elevationGain = run.elevationGain else { return "--" }
        return Measurement(value: elevationGain, unit: UnitLength.meters)
            .converted(to: .feet)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(0))))
    }
}

#Preview {
    RunCardView(run: Run(
        startDate: .now,
        endDate: .now.addingTimeInterval(1834),
        duration: 1834,
        distance: 3169,
        averageHeartRate: 142,
        elevationGain: 45
    ))
    .padding()
}
