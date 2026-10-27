//
//  ContentView.swift
//  Trackster
//
//  Created by Rowby Villanueva on 9/10/26.
//

import SwiftUI
import SwiftData

struct RootTabView: View {
    
    @State private var runViewModel = RunViewModel()
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var runContext

    var body: some View {
       
        TabView {
            
            Tab("History", systemImage: "figure.run.square.stack.fill") {
                HistoryView()
            }

            
            Tab("Start", systemImage: "record.circle") {
                RunMapView()
            }
     
            //TODO: make a profile view once there is login
//            Tab("Profile", systemImage: "person.crop.circle") {
//                ProfileView()
//            }
            
        }
        .environment(runViewModel)
        .task {
            runViewModel.restoreActiveRun(in: runContext)
        }
        .onChange(of: scenePhase, scenePhaseChanged)
    }

    private func scenePhaseChanged(_ oldPhase: ScenePhase, _ newPhase: ScenePhase) {
        switch newPhase {
        case .background:
            runViewModel.suspendPreviewLocation()
        case .active:
            runViewModel.resumePreviewLocation()
        default:
            break
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: [Run.self, RoutePoint.self], inMemory: true)
}
