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
    
    var body: some View {
        Map(position: $position) {
            UserAnnotation()
            MapPolyline(coordinates: viewModel.routeLocation.map(\.coordinate))
                .stroke(.orange, lineWidth: 5)
        }
            .mapControls {
                MapUserLocationButton()
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
