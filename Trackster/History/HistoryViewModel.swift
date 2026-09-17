//
//  HistoryViewModel.swift
//  Trackster
//
//  Created by Rowby Villanueva on 9/11/26.
//

import Foundation
import SwiftData


@Observable
class HistoryViewModel {
    
    private let healthKitManager = HealthKitManager()
    
    var showImportError = false
    var importErrorMessage = ""
    
    func importWorkouts(into runContext: ModelContext) async {
        do {
            try await healthKitManager.importWorkouts(into: runContext)
        } catch {
            
            importErrorMessage = "Couldn't import workouts from Apple Health. Check that Trackster has access in the Health app, then try again."
            showImportError = true
        }
    }
}


