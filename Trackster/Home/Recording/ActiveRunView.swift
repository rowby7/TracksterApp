//
//  ActiveRunView.swift
//  Trackster
//
//  Created by Rowby Villanueva on 9/11/26.
//

import SwiftUI
import SwiftData

struct ActiveRunView: View {
    @State private var viewModel = RunViewModel()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var runContext

    var body: some View {
        VStack {
            if let start = viewModel.startDate {
                TimelineView(.periodic(from: start, by: 0.03)) { context in
                    Text(viewModel.formattedElapsed(at: context.date))
                        .font(.largeTitle.scaled(by: 1.8).bold())
                        .monospacedDigit()
                }

                Grid {
                    GridRow {
                        Text("Distance")
                            .frame(maxWidth: .infinity)
                        Text("Pace")
                            .frame(maxWidth: .infinity)
                        Text("")
                    }
                    .font(.subheadline)

                    GridRow {
                        Text(distanceText)

                        TimelineView(.periodic(from: start, by: 1)) { context in
                            Text(paceText(at: context.date))
                        }
                    }
                    .font(.title.bold())
                    .monospacedDigit()
                }
                .padding(.vertical)
            } else {
                Text("00:00:00")
                    .font(.largeTitle.scaled(by: 1.8).bold())
                    .monospacedDigit()
            }

            Spacer()

            Button("Stop Recording", systemImage: "stop", action: stopRecording)
                .labelStyle(.iconOnly)
                .font(.largeTitle.scaled(by: 2))
        }
        .padding()
        .onAppear {
            viewModel.start()
        }
        .appTitle()
    }

    private var distanceText: String {
        Measurement(value: viewModel.totalDistance, unit: UnitLength.meters)
            .converted(to: .miles)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(2))))
    }

    private func paceText(at date: Date) -> String {
        let pace = viewModel.pace(at: date)
        guard pace > 0 else { return "-- /mi" }
        return Duration.seconds(pace).formatted(.time(pattern: .minuteSecond)) + " /mi"
    }

    private func stopRecording() {
        viewModel.stopAndSave(to: runContext)
        dismiss()
    }
}



#Preview {
    ActiveRunView()
}
