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
        
        if viewModel.isRunning {
            
        } else {
            HomeView()
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
           try? await viewModel.start()
        }
    }
}

#Preview {
    WorkoutView()
        .environment(WorkoutManager())
}
