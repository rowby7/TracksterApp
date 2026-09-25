//
//  RouteSnapshotView.swift
//  Trackster
//

import SwiftUI
import MapKit

struct RouteSnapshotView: View {
    let points: [RoutePoint]

    @Environment(\.displayScale) private var displayScale
    @State private var snapshot: MKMapSnapshotter.Snapshot?

    private let renderSize = CGSize(width: 480, height: 270)
    private let aspectRatio: CGFloat = 16 / 9

    var body: some View {
        Group {
            if let snapshot {
                Image(uiImage: snapshot.image)
                    .resizable()
            } else {
                Rectangle()
                    .fill(.quaternary)
            }
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
        .task {
            snapshot = try? await RouteSnapshotter().snapshot(
                for: points,
                size: renderSize,
                scale: displayScale
            )
            print("display Size: \(displayScale)")
        }
    }
}

#Preview("Route snapshot") {
    RouteSnapshotView(points: [
        RoutePoint(latitude: 40.7580, longitude: -73.9855, timestamp: .now),
        RoutePoint(latitude: 40.7614, longitude: -73.9776, timestamp: .now),
        RoutePoint(latitude: 40.7644, longitude: -73.9730, timestamp: .now),
        RoutePoint(latitude: 40.7681, longitude: -73.9712, timestamp: .now)
    ])
    .padding()
}
