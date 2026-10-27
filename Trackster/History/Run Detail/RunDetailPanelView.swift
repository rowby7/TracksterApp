//
//  RunDetailPanelView.swift
//  Trackster
//
//  Created by Rowby Villanueva on 10/17/26.
//

import SwiftUI
import SwiftData

struct RunDetailPanelView: View {
    let run: Run
    let splits: [Split]     // worked out once by RunDetailViewModel, not in body

    @ScaledMetric private var sectionSpacing = 28.0
    @ScaledMetric private var tileSpacing = 12.0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: sectionSpacing) {
                RunDetailHeaderView(run: run)

                RunDistanceHeroView(run: run)

                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: tileSpacing),
                              GridItem(.flexible(), spacing: tileSpacing)],
                    spacing: tileSpacing
                ) {
                    ForEach(stats) { stat in
                        RunDetailStatTile(stat: stat)
                    }
                }

                if !splits.isEmpty {
                    SplitsSectionView(splits: splits)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .padding(.top)
        }
        .scrollIndicators(.hidden)
    }

    private var stats: [RunDetailStat] {
        [
            RunDetailStat(title: "Duration", value: run.durationText,
                          systemImage: "stopwatch.fill", color: .yellow),
            RunDetailStat(title: "Avg. Pace", value: run.paceText,
                          systemImage: "figure.run", color: .cyan),
            RunDetailStat(title: "Avg. Speed", value: run.speedText,
                          systemImage: "gauge.with.dots.needle.67percent", color: .teal),
            RunDetailStat(title: "Elevation Gain", value: run.elevationGainText,
                          systemImage: "mountain.2.fill", color: .green),
            RunDetailStat(title: "Max Elevation", value: run.maxElevationText,
                          systemImage: "arrow.up.to.line", color: .mint),
            RunDetailStat(title: "Avg. Heart Rate", value: run.averageHeartRateText,
                          systemImage: "heart.fill", color: .red),
            RunDetailStat(title: "Active Energy", value: run.activeEnergyText,
                          systemImage: "flame.fill", color: .pink)
        ]
        .filter { $0.value != "--" }
    }
}

#if DEBUG
#Preview {
    // A real-looking run from the mock data, so the splits and every tile show up
    let container = try! ModelContainer(for: Run.self, RoutePoint.self,
                                        configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    MockData.seed(into: container.mainContext)
    let runs = try! container.mainContext.fetch(FetchDescriptor<Run>())
    let run = runs.first { $0.isImported } ?? runs[0]

    return RunDetailPanelView(run: run, splits: run.splits)
        .background(.black)
        .environment(\.colorScheme, .dark)
        .modelContainer(container)
}
#endif
