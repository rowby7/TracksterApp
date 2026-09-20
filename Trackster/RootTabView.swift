//
//  ContentView.swift
//  Trackster
//
//  Created by Rowby Villanueva on 9/10/26.
//

import SwiftUI
import SwiftData

struct RootTabView: View {
    var body: some View {
       
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView()
                   
            }
            
            Tab("History", systemImage: "figure.run.square.stack.fill") {
                HistoryView()
            }
            
            Tab("Profile", systemImage: "person.crop.circle") {
                ProfileView()
            }
            
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: Item.self, inMemory: true)
}
