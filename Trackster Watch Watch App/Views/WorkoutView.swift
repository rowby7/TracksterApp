//
//  WorkoutView.swift
//  Trackster Watch Watch App
//
//  Created by Rowby Villanueva on 10/23/26.
//

import SwiftUI

struct WorkoutView: View {
    
    @Environment(WorkoutManager.self) private var viewModel
    var body: some View {
        VStack(alignment: .leading) {
            
            
            if viewModel.isRunning {
                ActiveView()
            } else {
                HomeView()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .task {
            do {
                try await viewModel.requestAuthorization()
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

struct WorkoutCard: View {
    
    let title: String
    let result: String
    var unit: String? = nil

    var body: some View {
        // All white (the default .primary on a Watch), so every stat is easy to read
        VStack(alignment: .leading) {
            Text(title)
                .font(.footnote)

            // Unit sits on the number's baseline, in a smaller size
            HStack(alignment: .firstTextBaseline) {
                Text(result)
                    .font(.title.bold())
                    .fontDesign(.rounded)
                    .monospacedDigit()   // ticking digits don't shift sideways

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
//#Preview {
//    ActiveView()
//        .environment(WorkoutManager())
//}

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
