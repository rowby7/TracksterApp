//
//  LiveRunMapView.swift
//  Trackster
//
//  Created by Rowby Villanueva on 10/13/26.
//

import SwiftUI
import MapKit

struct LiveRunMapView: View {
    
    @Environment(RunViewModel.self) private var viewModel

    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var isShowingPanel = false
    @State private var isShowingGPSMessage = false
    @ScaledMetric private var countdownSize = 220.0
    
    var body: some View {
        Map(position: $position) {
            UserAnnotation()
            MapPolyline(coordinates: viewModel.routeLocation.map(\.coordinate))
                .stroke(.orange, lineWidth: 5)
        }
        .mapControls {
            MapUserLocationButton()
        }
        .overlay {
            if isShowingGPSMessage {
                Text(viewModel.isGPSReady ? "GPS acquired" : "Acquiring GPS...")
                    .font(.largeTitle.bold())
                    .padding()
                    .foregroundStyle(.white)
                    .background(viewModel.isGPSReady ? .green : .red, in: .rect(cornerRadius: 12))
            }
        }
        .overlay{
            if let countdown = viewModel.countdown {
                Text(countdown, format: .number)
                    .font(.largeTitle.scaled(by: 5).bold())
                    .monospacedDigit()
                    .frame(width: countdownSize, height: countdownSize)
                    .glassEffect(.regular.tint(.green.opacity(Double(countdown) * 0.3 - 0.1)), in: .circle)
                    .contentTransition(.numericText(countsDown: true))
                    .allowsHitTesting(false)
                    .accessibilityLabel("Starting in \(countdown)")
            }
        }
        .overlay(alignment: .bottomLeading) {
            if !isShowingPanel {
                Button("Show Run Panel", systemImage: "chevron.up", action: showPanel)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.glass)
                    .controlSize(.large)
                    .padding()
            }
        }
        .sheet(isPresented: $isShowingPanel) {
            ActiveRunView()
                .presentationDetents([.fraction(1 / 3)])
                .presentationBackgroundInteraction(.enabled)
                .presentationDragIndicator(.visible)
        }
        .sensoryFeedback(trigger: viewModel.countdown){ _, newNumber in
            switch newNumber {
            case 3: .impact(flexibility: .solid, intensity: 0.4)
            case 2: .impact(flexibility: .solid, intensity: 0.7)
            case 1: .impact(flexibility: .solid, intensity: 1.0)
             default: nil
            }
            
        }
        .task(id: viewModel.isGPSReady) {
            guard viewModel.isGPSReady else {
                isShowingGPSMessage = true
                return
            }
            try? await Task.sleep(for: .seconds(1.2))
            isShowingGPSMessage = false

        }
        .onAppear(perform: mapAppeared)
        .onDisappear(perform: mapDisappeared)
    }

    private func mapAppeared() {
        viewModel.startPreviewLocation()
        showPanel()
    }

    private func mapDisappeared() {
        viewModel.stopPreviewLocation()
    }

    private func showPanel() {
        isShowingPanel = true
    }
}

#Preview {
    LiveRunMapView()
        .environment(RunViewModel())
}
