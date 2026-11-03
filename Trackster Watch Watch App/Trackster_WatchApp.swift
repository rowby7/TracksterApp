//
//  Trackster_WatchApp.swift
//  Trackster Watch Watch App
//
//  Created by Rowby Villanueva on 10/23/26.
//

import SwiftUI

@main
struct Trackster_Watch_AppApp: App {
    // Made once here and shared, so every Watch screen sees the same workout
    @State private var workoutManager = WorkoutManager()

    var body: some Scene {
        WindowGroup {
            WorkoutView()
                .environment(workoutManager)
        }
    }
}
