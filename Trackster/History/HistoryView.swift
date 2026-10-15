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
    
    @Query(
        filter: #Predicate<Run> { run in !run.isActive},
        sort: \Run.startDate,
        order: .reverse
    ) private var runs: [Run]
    @State private var viewModel = HistoryViewModel()
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
                    ScrollView {
                        LazyVStack {
                            ForEach(runs) { run in
                                RunCardView(run: run)
                                    .padding()
                                    .contentShape(.rect)
                                    .contextMenu {
                                        Button("Delete", systemImage: "trash", role: .destructive) {
                                            deleteRun(run)
                                        }
                                    }
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .background(Color(.pageBackground))
            .navigationTitle("Run History")
            .navigationSubtitle("Keep Running")
            
            .task {
                await viewModel.importWorkouts(container: runContext.container)
            }
            .toolbar {
                if viewModel.isImporting && !runs.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        ProgressView()
                    }
                }
            }
            .alert("Unable to import Health Data", isPresented: $viewModel.showImportError) {
            } message: {
                Text(viewModel.importErrorMessage)
            }
            
        }
      
       
    }
    
    
    private func deleteRun(_ run: Run) {
          runContext.delete(run)
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

