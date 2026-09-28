//
//  RouteMapContent.swift
//  Trackster
//
//  Created by Rowby Villanueva on 9/27/26.
//
import SwiftUI
import MapKit

struct RouteMapContent: View {
    let snapshot: MKMapSnapshotter.Snapshot
    let points: [RoutePoint]
    let size: CGSize

    var body: some View {
        ZStack {
            Image(uiImage: snapshot.image)
                .resizable()

            Canvas { context, _ in
                context.stroke(routePath(), with: .color(.orange), lineWidth: 4)
            }
        }
        .frame(width: size.width, height: size.height)
    }

    private func routePath() -> Path {
        let ordered = points.sorted { $0.timestamp < $1.timestamp }
        let step = max(1, ordered.count / 200)

        let cgPoints = stride(from: 0, to: ordered.count, by: step).map { i in
            let p = ordered[i]
            let coordinate = CLLocationCoordinate2D(latitude: p.latitude, longitude: p.longitude)
            return snapshot.point(for: coordinate)
        }

        var path = Path()
        guard let first = cgPoints.first else { return path }
        path.move(to: first)
        for point in cgPoints.dropFirst() {
            path.addLine(to: point)
        }
        return path
    }
}
