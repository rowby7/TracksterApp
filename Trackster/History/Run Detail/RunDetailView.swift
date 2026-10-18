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
    @State private var isShowingPanel = true
    @State private var sheetHeight: PresentationDetent = .fraction(2 / 3)
    
    var body: some View {
        Map {
            
        }
        .ignoresSafeArea()
        .sheet(isPresented: $isShowingPanel) {
            RunDetailsSheet(run: run)
                .presentationDetents(
                    [.fraction(1 / 4), .fraction(2 / 3), .large],
                    selection: $sheetHeight
                )
        }
    }
}

struct RunDetailsSheet: View {
    let run: Run

    var body: some View {
        
    }
}

#Preview {
    RunDetailView(run: Run(startDate: .now, endDate: .now, duration: 1834, distance: 3169))
}
