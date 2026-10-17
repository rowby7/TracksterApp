//
//  RoutePoint.swift
//  Trackster
//
//  Created by Rowby Villanueva on 9/19/26.
//

import Foundation
import SwiftData

@Model
nonisolated final class RoutePoint {
    var latitude: Double
    var longitude: Double
    var timestamp: Date
    var altitude: Double?
    var run: Run?
    
    init(latitude: Double, longitude: Double, timestamp: Date, altitude: Double? = nil, run: Run? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
        self.altitude = altitude
        self.run = run
    }
}
