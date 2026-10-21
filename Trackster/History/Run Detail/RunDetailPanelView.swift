//
//  RunDetailViewPanel.swift
//  Trackster
//
//  Created by Rowby Villanueva on 10/17/26.
//

import SwiftUI

struct RunDetailPanelView: View {
    let run: Run
    var body: some View {
        ScrollView {
            Grid (verticalSpacing: 30){
        
                GridRow {
                    RunDetailStatView(title: "Distance", value: run.distanceText)

                }
                GridRow {
                    RunDetailStatView(title: "Pace", value: run.paceText)

                    RunDetailStatView(title: "Duration", value: run.durationText)
                }
                GridRow {
                    RunDetailStatView(title: "Elevation Gain", value: run.elevationGainText)

                    RunDetailStatView(title: "Max Elevation", value: run.maxElevationText)
                }
                
                GridRow {
                    RunDetailStatView(title: "Avg. Heart Rate", value: run.averageHeartRateText)

                    RunDetailStatView(title: "Active Energy", value: run.activeEnergyText)
                }
                
                GridRow {
                    RunDetailStatView(title: "Avg. Speed", value: run.speedText)

                }
                
            }
            
        }
        .padding()
        .padding(.top)
        
    }
}

struct RunDetailStatView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.largeTitle.bold())
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    RunDetailPanelView(run: Run(startDate: .now, endDate: .now, duration: 1834, distance: 3169))
}
