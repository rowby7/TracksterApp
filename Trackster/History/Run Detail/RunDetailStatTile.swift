//
//  RunDetailStatTile.swift
//  Trackster
//

import SwiftUI

/// A rounded tile with a colored icon and value, in the style of Apple Fitness summaries.
struct RunDetailStatTile: View {
    let stat: RunDetailStat

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label {
                Text(stat.title)
                    .foregroundStyle(.secondary)
            } icon: {
                Image(systemName: stat.systemImage)
                    .foregroundStyle(stat.color)
            }
            .font(.subheadline)

            Text(stat.value)
                .font(.title2.bold())
                .fontDesign(.rounded)
                .monospacedDigit()
                .foregroundStyle(stat.color)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.fill.tertiary, in: .rect(cornerRadius: 18))
        // VoiceOver reads the tile as one item: "Duration, 0:18:28"
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    RunDetailStatTile(stat: RunDetailStat(title: "Avg. Heart Rate", value: "156 bpm",
                                          systemImage: "heart.fill", color: .red))
        .padding()
        .background(.black)
        .environment(\.colorScheme, .dark)
}
