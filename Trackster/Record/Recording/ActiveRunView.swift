//
//  ActiveRunView.swift
//  Trackster
//
//  Created by Rowby Villanueva on 9/11/26.
//

import SwiftUI
import SwiftData

struct ActiveRunView: View {
    @Environment(RunViewModel.self) private var viewModel
    @Environment(\.modelContext) private var runContext
    @Namespace private var buttonNamespace

    
    var body: some View {
        VStack {
            if let start = viewModel.startDate {
                TimelineView(.periodic(from: start, by: 0.03)) { context in
                    Text(viewModel.formattedElapsed(at: context.date))
                        .font(.largeTitle.scaled(by: 1.8).bold())
                        .monospacedDigit()
                }
            
            } else {
                Text("00:00:00")
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

                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        Text(paceText(at: context.date))
                    }
                }
                .font(.title.bold())
                .monospacedDigit()
            }
            .padding(.vertical)

            GlassEffectContainer {
                HStack {
                    
                    if viewModel.isRunning {
                        pauseButton
                            .hidden()
                    }

                    Button(
                        viewModel.isRunning ? "Stop Recording" : "Start",
                        systemImage: viewModel.isRunning ? "stop.fill" : "play.fill",
                        action: toggleRun
                    )
                    .labelStyle(.iconOnly)
                    .font(.largeTitle)
                    .buttonStyle(.glassProminent)
                    .buttonBorderShape(.circle)
                    .controlSize(.extraLarge)
                    .tint(.orange)
                    .glassEffectID("main", in: buttonNamespace)

                    
                    if viewModel.isRunning {
                        pauseButton
                            .glassEffectID("pause", in: buttonNamespace)
                    }
                }
            }
            .animation(.default, value: viewModel.isRunning)
          
        }
        .padding()
        .padding(.top, 20)

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

    private var pauseButton: some View {
        Button(
            viewModel.isPaused ? "Resume" : "Pause Recording",
            systemImage: viewModel.isPaused ? "play.fill" : "pause.fill",
            action: togglePause
        )
        .labelStyle(.iconOnly)
        .font(.title)
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .controlSize(.large)
        
    }

    private func togglePause() {
        if viewModel.isPaused {
            viewModel.resume()
        } else {
            viewModel.pause()
        }
    }

    private func toggleRun() {
        if viewModel.isRunning {
            viewModel.stopAndSave(to: runContext)
        } else {
            viewModel.start()
        }
    }
}



#Preview {
    ActiveRunView()
        .environment(RunViewModel())
}
