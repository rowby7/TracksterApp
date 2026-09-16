//
//  StopwatchViewModel.swift
//  Trackster
//
//  Created by Rowby Villanueva on 9/11/26.
//

import Foundation
import SwiftData

@Observable
class RunViewModel {
    private(set) var startDate: Date?
    private(set) var isRunning = false

    func start() {
        startDate = Date.now
        isRunning = true
    }

    func elapsed(at date: Date) -> TimeInterval {
        guard let startDate else { return 0 }
        return date.timeIntervalSince(startDate)
    }

    func formattedElapsed(at date: Date) -> String {
        let interval = elapsed(at: date)
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        let milliseconds = Int((interval.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d:%02d", minutes, seconds, milliseconds)
    }

    func stopAndSave(to runContext: ModelContext) {
        isRunning = false
        guard let startDate else { return }
        let record = Run(startDate: startDate, endDate: .now, duration: elapsed(at: .now))
        runContext.insert(record)
    }
}
