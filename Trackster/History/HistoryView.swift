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
    
    @Query(sort: \Run.startDate, order: .reverse) private var runs: [Run]
    @State private var healthKitManager = HealthKitManager()
    @Environment(\.modelContext) private var runContext
    
    var body: some View {
        NavigationStack {
            Group {
                if runs.isEmpty {
                    ContentUnavailableView(
                        "No Runs Yet",
                        systemImage: "figure.run.circle",
                        description: Text("Start a run or import from Apple Health to see it here.")
                    )
                } else {
                    List {
                        ForEach(runs) { run in
                            TimerDisplayView(run: run)
                                .listRowSeparator(.hidden)
                                .glassEffect()
                                .swipeActions(edge: .trailing) {
                                    Button("Delete", systemImage: "trash", role: .destructive) {
                                        deleteRun(run)
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                    
                    
                }
            }
            .appTitle("Run History")
            .task {
                try? await healthKitManager.importWorkouts(into: runContext)
            }
        }
      
       
    }
    
    
    private func deleteRun(_ run: Run) {
          runContext.delete(run)
      }
}


// MARK: - Timer display

struct TimerDisplayView: View {
    let run: Run
    
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
//        .background {
//            RoundedRectangle(cornerRadius: 16)
//                .fill(.background)
//                .shadow(radius: 2)
//        }
        .padding(.horizontal, 12)

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


