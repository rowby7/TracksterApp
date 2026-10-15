//
//  RunPhase.swift
//  Trackster
//

/// The one state a recording is in at any moment.
enum RunPhase {
    case idle
    case countingDown
    case running
    case paused
}
