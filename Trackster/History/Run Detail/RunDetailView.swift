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
