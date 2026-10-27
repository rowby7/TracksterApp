//
//  SplitsSectionView.swift
//  Trackster
//

import SwiftUI

/// The per-mile list, with bars so the fast and slow miles stand out at a glance.
struct SplitsSectionView: View {
    let splits: [Split]

    var body: some View {
        // Worked out once per render, not once per row
        let fastestID = fastestSplit?.id
        let paceRange = (splits.map(\.pace).min() ?? 0)...(splits.map(\.pace).max() ?? 0)

        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text("Splits")
                    .font(.title2.bold())
                    .fontDesign(.rounded)
                Spacer()
                Text("Pace")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            ForEach(splits) { split in
                SplitRowView(
                    split: split,
                    barFraction: barFraction(for: split, paceRange: paceRange),
                    isFastest: split.id == fastestID,
                    isPartial: split.id == splits.last?.id && split.distance < Split.metersPerMile - 1
                )
            }
        }
        .padding()
        .background(.fill.quaternary, in: .rect(cornerRadius: 22))
    }

    /// Only full miles compete for fastest, so a quick sprint over the last 0.1 mi doesn't win
    private var fastestSplit: Split? {
        let fullMiles = splits.filter { $0.distance >= Split.metersPerMile - 1 }
        return (fullMiles.isEmpty ? splits : fullMiles).min { $0.pace < $1.pace }
    }

    /// The fastest mile fills the bar; the slowest fills about a third, so differences are easy to see
    private func barFraction(for split: Split, paceRange: ClosedRange<TimeInterval>) -> Double {
        let fastest = paceRange.lowerBound
        let slowest = paceRange.upperBound
        guard slowest > fastest else { return 1 }
        let quickness = (slowest - split.pace) / (slowest - fastest)
        return 0.35 + 0.65 * quickness
    }
}
