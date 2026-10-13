//
//  LiveRunMapView.swift
//  Trackster
//
//  Created by Rowby Villanueva on 10/13/26.
//

import SwiftUI
import MapKit

struct LiveRunMapView: View {
    
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var isShowingPanel = false
    @ScaledMetric private var panelHeight = 250.0
    
    var body: some View {
        Map(position: $position) { UserAnnotation() }
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
                    .presentationDetents([.height(panelHeight)])
                    .presentationBackgroundInteraction(.enabled)
                    .presentationDragIndicator(.visible)
            }
            .onAppear(perform: showPanel)
    }

    private func showPanel() {
        isShowingPanel = true
    }
}

#Preview {
    LiveRunMapView()
        .environment(RunViewModel())
}
