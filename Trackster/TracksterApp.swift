//
//  TracksterApp.swift
//  Trackster
//
//  Created by Rowby Villanueva on 9/10/26.
//

import SwiftUI
import SwiftData

@main
struct TracksterApp: App {
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            RoutePoint.self,
            Run.self
        ])
        #if DEBUG
        // Screenshot mode: a throwaway database of sample runs, so real data is never touched
        if MockData.isEnabled {
            let mockConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            let container = try! ModelContainer(for: schema, configurations: [mockConfiguration])
            MockData.seed(into: container.mainContext)
            return container
        }
        #endif

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .preferredColorScheme(.light)
        }
        .modelContainer(sharedModelContainer)
    }
}
