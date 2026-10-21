//
//  RunDetailView.swift
//  Trackster
//
//  Created by Rowby Villanueva on 10/17/26.
//

import SwiftUI
import MapKit

struct RunDetailView: View {
    
    let run: Run
    @State private var viewModel: RunDetailViewModel
    @State private var isShowingPanel = true
    @State private var sheetHeight: PresentationDetent = .fraction(1 / 4)
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(run: Run) {
        self.run = run
        _viewModel = State(initialValue: RunDetailViewModel(run: run))
    }
    
    var body: some View {
        Map {
            MapPolyline(coordinates: viewModel.visibleCoordinates)
                .stroke(.orange, lineWidth: 5)

            if let runner = viewModel.runnerCoordinate {
                Annotation("Runner", coordinate: runner) {
                    Circle()
                        .fill(.orange)
                        .frame(width: 16, height: 16)
                        .overlay { Circle().strokeBorder(.white, lineWidth: 3) }
                }
            }
        }
        .ignoresSafeArea()
        .task {
            viewModel.loadRoute()
            // Reduce Motion users get the whole route at once instead of the drawing animation
            await viewModel.drawRoute(animated: !reduceMotion)
        }
        .sheet(isPresented: $isShowingPanel) {
            RunDetailPanelView(run: run)
                .presentationBackground(.black)
                .environment(\.colorScheme, .dark)
                .presentationDetents(
                    [.fraction(1 / 4), .fraction(2 / 3), .large],
                    selection: $sheetHeight
                )
        }
    }
}



#Preview {
    RunDetailView(run: Run(startDate: .now, endDate: .now, duration: 1834, distance: 3169))
}
