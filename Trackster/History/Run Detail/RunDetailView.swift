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
            if let start = viewModel.coordinates.first {
                Marker("Start", systemImage: "flag.fill", coordinate: start)
                    .tint(.green)
            }
            if viewModel.isDrawingFinished, let finish = viewModel.coordinates.last {
                Marker("Finish", systemImage: "flag.checkered", coordinate: finish)
                      .tint(.black)
            }
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
            await viewModel.drawRoute(animated: !reduceMotion)
        }
        .sheet(isPresented: $isShowingPanel) {
            RunDetailPanelView(run: run, splits: viewModel.splits)
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
