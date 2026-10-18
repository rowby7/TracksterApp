//
//  Run+Splits.swift
//  Trackster
//

extension Run {
    /// Calculated from the route each time it's read, so it's always in step with the points
    var splits: [Split] {
        Split.perMile(from: route)
    }
}
