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
                VStack (spacing: 20){
                    
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
        Map(interactionModes: []) .aspectRatio(16/9, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(12)
            .background(.background, in: RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 2)
    }
}

#Preview {
    HistoryView()
}
