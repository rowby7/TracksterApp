//
//  HomeView.swift
//  Trackster
//
//  Created by Rowby Villanueva on 9/11/26.
//

import SwiftUI

struct RecordRunView: View {
    var body: some View {
        NavigationStack {
            NavigationLink(value: HomeRoute.recording) {
                VStack {
                    Image(systemName: "play.fill")
                    Text("Start Run")
                }
            }
            .navigationDestination(for: HomeRoute.self) { _ in
                ActiveRunView()
            }
            .font(.largeTitle)
            .appTitle()
        }
    }
}

enum HomeRoute: Hashable { case recording }

#Preview {
    RecordRunView()
}
