//
//  RunDetailView.swift
//  Trackster
//
//  Created by Rowby Villanueva on 10/17/26.
//

import SwiftUI
import MapKit

struct RunDetailView: View {
    
    @State private var isShowingPanel = true
    @State private var sheetHeight: PresentationDetent = .fraction(2 / 3)
    
    var body: some View {
        Map {
            
        }
        .ignoresSafeArea()
        .sheet(isPresented: $isShowingPanel) {
            RunDetailsSheet()
                .presentationDetents(
                    [.fraction(1 / 4), .fraction(2 / 3), .large],
                    selection: $sheetHeight
                )
        }
    }
}

struct RunDetailsSheet: View {
    var body: some View {
        
    }
}

#Preview {
    RunDetailView()
}
