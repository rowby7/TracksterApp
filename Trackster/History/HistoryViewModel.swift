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
    var isImporting = false
    
    
    func importWorkouts(container: ModelContainer) async {
        isImporting = true
        defer { isImporting = false }
        do {
            try await healthKitManager.requestAuthorization()
            let importer = RunImporter(modelContainer: container)
            try await importer.importWorkouts()
        } catch {
            
            importErrorMessage = "Couldn't import workouts from Apple Health. Check that Trackster has access in the Health app, then try again."
            showImportError = true
        }
    }
}


