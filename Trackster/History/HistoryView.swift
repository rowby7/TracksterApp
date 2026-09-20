//
//  HistoryView.swift
//  Trackster
//
//  Created by Rowby Villanueva on 9/11/26.
//

import SwiftUI
import MapKit
import SwiftData

struct HistoryView: View {
    
    @Query(sort: \Run.startDate, order: .reverse) private var runs: [Run]
    @State private var viewModel = HistoryViewModel()
    @Environment(\.modelContext) private var runContext
    
    var body: some View {
        NavigationStack {
            Group {
                if runs.isEmpty {
                    ContentUnavailableView(
                        "No Runs Yet",
                        systemImage: "figure.run.circle",
                        description: Text("Start a run or import from Apple Health to see it here.")
                    )
                } else {
                    List {
                        ForEach(runs) { run in
                            TimerDisplayView(run: run)
                                .listRowSeparator(.visible)
                                .swipeActions(edge: .trailing) {
                                    Button("Delete", systemImage: "trash", role: .destructive) {
                                        deleteRun(run)
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                    .scrollIndicators(.hidden)
                    
                    
                }
            }
            .appTitle("Run History")
            .task {
                await viewModel.importWorkouts(container: runContext.container)
            }
            .toolbar {
                if viewModel.isImporting && !runs.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        ProgressView()
                    }
                }
            }
            .alert("Unable to import Health Data", isPresented: $viewModel.showImportError) {
            } message: {
                Text(viewModel.importErrorMessage)
            }
          
        }
      
       
    }
    
    
    private func deleteRun(_ run: Run) {
          runContext.delete(run)
      }
}


// MARK: - Timer display

struct TimerDisplayView: View {
    let run: Run

    var body: some View {
        
        HStack(alignment: .top){
            VStack(alignment: .leading, spacing: 10) {
                Text(run.startDate, format: .dateTime.day().month().year())
                    .font(.subheadline)
                    .opacity(0.6)
                
                HStack (spacing: 20){
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
        
    }

    private var distanceText: String {
        guard let distance = run.distance else { return "--" }
        return Measurement(value: distance, unit: UnitLength.meters)
            .converted(to: .miles)
            .formatted(.measurement(width: .abbreviated, numberFormatStyle: .number.precision(.fractionLength(2))))
    }

    private var bpmText: String {
        guard let bpm = run.averageHeartRate else { return "--" }
        return "\(Int(bpm.rounded())) bpm"
    }

    private var elevationGainText: String {
        guard let elevationGain = run.elevationGain else { return "--" }
        return Measurement(value: elevationGain, unit: UnitLength.meters)
            .converted(to: .feet)
            .formatted(.measurement(width: .abbreviated, numberFormatStyle: .number.precision(.fractionLength(0))))
    }

}

private struct StatColumnView: View {
    let title: String
    let value: String

    var body: some View {
        VStack (alignment: .leading){
            Text(title)
                .font(.caption)
            Text(value)
                .font(.title2)
        }
    }
}

#Preview("Timer Display") {
    TimerDisplayView(run: Run(
        startDate: .now,
        endDate: .now.addingTimeInterval(1834),
        duration: 1834,
        distance: 3169,
        averageHeartRate: 142,
        elevationGain: 45
    ))
    .glassEffect()
    .padding()
}


// TODO: map card for gps
//struct MapCardView: View {
//    var body: some View {
//        Map(interactionModes: []) .aspectRatio(16/9, contentMode: .fit)
//            .frame(maxWidth: .infinity)
//            .clipShape(RoundedRectangle(cornerRadius: 16))
//            .padding(12)
//            .background(.background, in: RoundedRectangle(cornerRadius: 20))
//            .shadow(radius: 2)
//    }
//}

#Preview {
    HistoryView()
}

