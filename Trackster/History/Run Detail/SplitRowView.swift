//
//  SplitRowView.swift
//  Trackster
//

import SwiftUI

/// One mile: its number, a bar showing how quick it was next to the others, and its pace.
struct SplitRowView: View {
    let split: Split
    let barFraction: Double     // 1 for the fastest mile, smaller for slower ones
    let isFastest: Bool
    let isPartial: Bool         // the short leftover at the end of the run

    @ScaledMetric private var mileColumnWidth = 28.0
    @ScaledMetric private var barHeight = 10.0

    var body: some View {
        HStack(spacing: 12) {
            Text(split.number, format: .number)
                .font(.headline)
                .monospacedDigit()
                .frame(width: mileColumnWidth, alignment: .leading)

            Capsule()
                .fill(.fill.tertiary)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(isFastest ? AnyShapeStyle(.orange) : AnyShapeStyle(.orange.secondary))
                        .scaleEffect(x: barFraction, anchor: .leading)
                }
                .clipShape(.capsule)
                .frame(height: barHeight)
                .accessibilityHidden(true)

            VStack(alignment: .trailing, spacing: 0) {
                Text(split.paceText)
                    .font(.body.bold())
                    .fontDesign(.rounded)
                    .monospacedDigit()
                    .foregroundStyle(isFastest ? AnyShapeStyle(.orange) : AnyShapeStyle(.primary))

                if isPartial {
                    Text(split.distanceText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        let pace = Duration.seconds(split.pace).formatted(.units(allowed: [.minutes, .seconds], width: .wide))
        var text = "Mile \(split.number), \(pace) per mile"
        if isPartial { text += ", partial mile, \(split.distanceText)" }
        if isFastest { text += ", fastest" }
        return text
    }
}
