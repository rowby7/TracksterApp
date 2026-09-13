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
            
            Tab("History", systemImage: "archivebox") {
                HistoryView()
            }
            
            Tab("Profile", systemImage: "person.crop.circle") {
                Text("Profile")
            }
            
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: Item.self, inMemory: true)
}
