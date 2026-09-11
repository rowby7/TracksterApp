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
            Text("Home")
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "archivebox")
                }
            
            Text("Profile")
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: Item.self, inMemory: true)
}
