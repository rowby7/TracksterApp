//
//  RouteSnapshotter.swift
//  Trackster
//
//  Created by Rowby Villanueva on 9/23/26.
//

import Foundation
import MapKit
import SwiftUI
import SwiftData

@MainActor
final class RouteSnapshotter {
    static let shared = RouteSnapshotter()
    private init() {}

    private let cache = NSCache<NSString, UIImage>()

    func image(
        for points: [RoutePoint],
        id: PersistentIdentifier,
        size: CGSize,
        scale: CGFloat
    ) async -> UIImage? {
        let key = String(describing: id) as NSString

        if let cached = cache.object(forKey: key) {
            return cached
        }

        guard let snapshot = try? await snapshot(for: points, size: size, scale: scale) else {
            return nil
        }

        let renderer = ImageRenderer(
            content: RouteMapContent(snapshot: snapshot, points: points, size: size)
        )
        renderer.scale = scale

        guard let image = renderer.uiImage else { return nil }

        cache.setObject(image, forKey: key)
        return image
    }

    private func snapshot(for points: [RoutePoint], size: CGSize, scale: CGFloat) async throws -> MKMapSnapshotter.Snapshot? {

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
