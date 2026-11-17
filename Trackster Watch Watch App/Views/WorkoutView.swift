//
//  WorkoutView.swift
//  Trackster Watch Watch App
//
//  Created by Rowby Villanueva on 10/23/26.
//

import SwiftUI

enum Page {
    case stats
    case controls
}
struct WorkoutView: View {
    
    @Environment(WorkoutManager.self) private var viewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            if viewModel.isRunning {
                TabbedView()
            } else {
                HomeView()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .task {
            do {
                try await viewModel.requestAuthorization()
                viewModel.requestLocationAuthorization()
            } catch {
                print("Health permission failed: \(error)")
            }
        }
    }

 
}


struct HomeView: View {
    
    @Environment(WorkoutManager.self) private var viewModel
    var body: some View {
        NavigationStack {
            Button(action: startWorkout) {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "figure.run")
                        .font(.title2)
                        .foregroundStyle(.orange)
                        .padding(10)
                        .background(.orange.tertiary, in: .circle)
                    
                    Text("Outdoor Run")
                        .font(.headline)
                    
                    Text("GPS · Heart Rate")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 4)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.roundedRectangle(radius: 24))
            .accessibilityLabel("Start outdoor run")
            .padding(.horizontal)
            .navigationTitle("Trackster")
        }
    }
    
    private func startWorkout() {
        Task {
            do {
                try await viewModel.start()
            } catch {
                print("Starting the workout failed: \(error)")
            }
        }
    }
}

struct TabbedView: View {
    @State private var selection: Page = .stats
    
    var body: some View {
        TabView(selection: $selection) {
            ControlsView()
                .tag(Page.controls)
            ActiveView()
                .tag(Page.stats)
        }
        .tabViewStyle(.page)
    }
}
struct ActiveView: View {
    @Environment(WorkoutManager.self) private var viewModel
    
    var body: some View {
        ScrollView {
            TimelineView(.periodic(from: .now, by: 1)) { _ in
                
                VStack(alignment: .leading) {
                    WorkoutCard(title: "Time", result: "\(Duration.seconds(viewModel.elapsedTime).formatted(.time(pattern:.minuteSecond)))")
                    WorkoutCard(title: "Heart Rate" , result: "\(viewModel.heartRate.formatted(.number.precision(.fractionLength(0))))", unit: "BPM")
                    WorkoutCard(title: "Pace", result: "\(Duration.seconds(viewModel.pace).formatted(.time(pattern:.minuteSecond)))", unit: "/mi")
                    WorkoutCard(title: "Distance", result: "\(viewModel.miles.formatted(.number.precision(.fractionLength(2))))", unit: "mi")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
       
        }
    }
}


struct ControlsView: View {
    @Environment(WorkoutManager.self) private var viewModel
    var body: some View {
        HStack {
            ControlButton(title: "End", systemImage: "xmark", tint: .red, action: endWorkout)

            // Shows Pause while running, Resume while paused
            ControlButton(
                title: viewModel.isPaused ? "Resume" : "Pause",
                systemImage: viewModel.isPaused ? "play.fill" : "pause.fill",
                tint: .yellow,
                action: togglePause
            )
        }
    }

    private func togglePause() {
        // TODO (yours): call pause() or resume() on viewModel, depending on isPaused
        viewModel.isPaused ? viewModel.resume() : viewModel.pause()
    }

    private func endWorkout() {
        Task {
            do {
                try await viewModel.end()
            } catch {
                print("Ending the workout failed: \(error)")
            }
        }
    }
}

/// A round, tinted Watch control with its caption underneath.
struct ControlButton: View {
    let title: String
    let systemImage: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        VStack {
            Button(title, systemImage: systemImage, action: action)
                .labelStyle(.iconOnly)       // VoiceOver still reads the title
                .font(.title2.bold())
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
                .controlSize(.large)
                .tint(tint)

            // Visible caption only; the button already says the title to VoiceOver
            Text(title)
                .accessibilityHidden(true)
        }
    }
}

struct WorkoutCard: View {
    
    let title: String
    let result: String
    var unit: String? = nil

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.footnote)

            HStack(alignment: .firstTextBaseline) {
                Text(result)
                    .font(.title.bold())
                    .fontDesign(.rounded)
                    .monospacedDigit()

                if let unit {
                    Text(unit)
                        .font(.footnote.bold())
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)   // VoiceOver: "Heart Rate, 156, BPM"
    }
}

#Preview {
    ScrollView {
        VStack(alignment: .leading) {
            WorkoutCard(title: "Time", result: "18:42")
            WorkoutCard(title: "Heart Rate", result: "156", unit: "BPM")
            WorkoutCard(title: "Pace", result: "9:47", unit: "/mi")
            WorkoutCard(title: "Distance", result: "1.91", unit: "mi")
        }
    }
}

#Preview("Controls") {
    ControlsView()
        .environment(WorkoutManager())
}
