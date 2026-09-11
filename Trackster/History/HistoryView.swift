//
//  HistoryView.swift
//  Trackster
//
//  Created by Rowby Villanueva on 9/11/26.
//

import SwiftUI
import MapKit

struct HistoryView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack (spacing: 10){
                    
                    MapCardView()
                    MapCardView()
                    MapCardView()

                    
                    
                }
                .padding(.horizontal, 30)
            }
        }
    }
}


struct MapCardView: View {
    var body: some View {
        Map(interactionModes: []) // Disables all interactions
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(12)
            .background(.background, in: RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 2)
    }
}

#Preview {
    HistoryView()
}
