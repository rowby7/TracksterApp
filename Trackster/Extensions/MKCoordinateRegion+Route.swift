//
//  MKCoordinateRegion+Route.swift
//  Trackster
//
//  Created by Rowby Villanueva on 9/23/26.
//

import Foundation
import MapKit

extension MKCoordinateRegion {
    init?(fitting points: [RoutePoint]) {
        guard let minLat = points.map(\.latitude).min(),
              let maxLat = points.map(\.latitude).max(),
              let minLon = points.map(\.longitude).min(),
              let maxLon = points.map(\.longitude).max()
        else { return nil }

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )

        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.3, 0.002),
            longitudeDelta: max((maxLon - minLon) * 1.3, 0.002)
        )

        self.init(center: center, span: span)
    }
}
