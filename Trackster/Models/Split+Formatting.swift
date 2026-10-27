//
//  Split+Formatting.swift
//  Trackster
//

import Foundation

// Display text for a split, formatted the same way as Run+Formatting
extension Split {

    var paceText: String {
        Duration.seconds(pace).formatted(.time(pattern: .minuteSecond)) + " /mi"
    }

    var durationText: String {
        Duration.seconds(duration).formatted(.time(pattern: .minuteSecond))
    }

    /// "1.00 mi" for full miles, or the short leftover, like "0.17 mi"
    var distanceText: String {
        Measurement(value: distance, unit: UnitLength.meters)
            .converted(to: .miles)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided,
                                    numberFormatStyle: .number.precision(.fractionLength(2))))
    }
}
