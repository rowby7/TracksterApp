//
//  Run+Formatting.swift
//  Trackster
//

import Foundation

// Display text for every stat on a run, so each screen formats them the same way
extension Run {

    var dateText: String {
        startDate.formatted(date: .abbreviated, time: .shortened)
    }

    var durationText: String {
        Duration.seconds(duration).formatted(.time(pattern: .hourMinuteSecond))
    }

    var distanceText: String {
        guard let distance else { return "--" }
        return Measurement(value: distance, unit: UnitLength.meters)
            .converted(to: .miles)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided,
                                    numberFormatStyle: .number.precision(.fractionLength(2))))
    }

    var paceText: String {
        guard let distance, distance > 0 else { return "--" }
        let secondsPerMile = duration / (distance / 1609.344)
        return Duration.seconds(secondsPerMile).formatted(.time(pattern: .minuteSecond)) + " /mi"
    }

    /// Average speed over the whole run, in miles per hour
    var speedText: String {
        guard let distance, distance > 0, duration > 0 else { return "--" }
        return Measurement(value: distance / duration, unit: UnitSpeed.metersPerSecond)
            .converted(to: .milesPerHour)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided,
                                    numberFormatStyle: .number.precision(.fractionLength(1))))
    }

    var averageHeartRateText: String {
        guard let averageHeartRate else { return "--" }
        return "\(Int(averageHeartRate.rounded())) bpm"
    }

    var activeEnergyText: String {
        guard let activeEnergy else { return "--" }
        return "\(Int(activeEnergy.rounded())) cal"
    }

    var elevationGainText: String {
        guard let elevationGain else { return "--" }
        return feetText(elevationGain)
    }

    var maxElevationText: String {
        guard let maxElevation else { return "--" }
        return feetText(maxElevation)
    }

    private func feetText(_ meters: Double) -> String {
        Measurement(value: meters, unit: UnitLength.meters)
            .converted(to: .feet)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided,
                                    numberFormatStyle: .number.precision(.fractionLength(0))))
    }
}
