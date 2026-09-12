//
//  HomeView.swift
//  Trackster
//
//  Created by Rowby Villanueva on 9/11/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            NavigationLink(value: HomeRoute.recording) {
                VStack {
                    Image(systemName: "play.fill")
                    Text("Start Run")
                }
            }
            .navigationDestination(for: HomeRoute.self) { _ in
                RecordingView()
            }
            .font(.largeTitle)
        }
    }
}

enum HomeRoute: Hashable { case recording }

#Preview {
    HomeView()
}
