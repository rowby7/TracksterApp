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
    var body: some View {
       
        TabView {
            
            Tab("History", systemImage: "figure.run.square.stack.fill") {
                HistoryView()
            }

            
            Tab("Start", systemImage: "record.circle") {
                LiveRunMapView()
            }
     
            Tab("Profile", systemImage: "person.crop.circle") {
                ProfileView()
            }
            
        }
        .environment(runViewModel)
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: Item.self, inMemory: true)
}
