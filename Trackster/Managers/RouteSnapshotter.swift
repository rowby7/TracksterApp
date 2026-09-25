//
//  RouteSnapshotter.swift
//  Trackster
//
//  Created by Rowby Villanueva on 9/23/26.
//

import Foundation
import MapKit

final class RouteSnapshotter {
    
    func snapshot(for points: [RoutePoint], size: CGSize, scale: CGFloat) async throws -> MKMapSnapshotter.Snapshot? {

        guard let region = MKCoordinateRegion(fitting: points) else { return nil }

        let options = MKMapSnapshotter.Options()
        options.region = region
        options.size = size
        options.scale = scale
        options.pointOfInterestFilter = .excludingAll
        
        let snapshotter = MKMapSnapshotter(options: options)
        return try await snapshotter.start()
        
    }
}
