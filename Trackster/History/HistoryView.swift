//
//  HistoryView.swift
//  Trackster
//
//  Created by Rowby Villanueva on 9/11/26.
//

import SwiftUI
import MapKit
import SwiftData

struct HistoryView: View {
    
    @Query(sort: \StopwatchModel.startDate, order: .reverse) private var runs: [StopwatchModel]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(runs) { run in
                        TimerDisplayView(run: run)
                    }
                    .padding(.horizontal, 12)
                }
                .appTitle("History")
            }
        }
    }
}


// MARK: - Timer display

struct TimerDisplayView: View {
    let run: StopwatchModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            Text(run.startDate, format: .dateTime.day().month().year())
                .font(.subheadline)
                .opacity(0.6)
                .padding(.horizontal, 3)
            
            Text(Duration.seconds(run.duration), format: .time(pattern: .minuteSecond))
                .font(.largeTitle.bold())
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .shadow(radius: 2)
        }

    }
}
// TODO: map card for gps
//struct MapCardView: View {
//    var body: some View {
//        Map(interactionModes: []) .aspectRatio(16/9, contentMode: .fit)
//            .frame(maxWidth: .infinity)
//            .clipShape(RoundedRectangle(cornerRadius: 16))
//            .padding(12)
//            .background(.background, in: RoundedRectangle(cornerRadius: 20))
//            .shadow(radius: 2)
//    }
//}

#Preview {
    HistoryView()
}


