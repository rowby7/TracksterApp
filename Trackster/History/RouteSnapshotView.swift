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
                ZStack {
                    Image(uiImage: snapshot.image)
                        .resizable()
                    
                    Canvas { context, size in
                        let path = routePath(in: snapshot, canvasSize: size)
                        context.stroke(path, with: .color(.orange), lineWidth: 4)
                    }
                }
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
    
    private func routePath(in snapshot: MKMapSnapshotter.Snapshot, canvasSize: CGSize) -> Path {
        let scale = canvasSize.width / renderSize.width
        
        let ordered = points.sorted { $0.timestamp < $1.timestamp }
        let step = max(1, ordered.count / 200)

        let cgPoints = stride(from: 0, to: ordered.count, by: step).map { i in
            let p = ordered[i]
            let coordinate = CLLocationCoordinate2D(latitude: p.latitude, longitude: p.longitude)
            let raw = snapshot.point(for: coordinate)
            return CGPoint(x: raw.x * scale, y: raw.y * scale)
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

#Preview("Route snapshot") {
    RouteSnapshotView(points: [
        RoutePoint(latitude: 40.7580, longitude: -73.9855, timestamp: .now),
        RoutePoint(latitude: 40.7614, longitude: -73.9776, timestamp: .now),
        RoutePoint(latitude: 40.7644, longitude: -73.9730, timestamp: .now),
        RoutePoint(latitude: 40.7681, longitude: -73.9712, timestamp: .now)
    ])
    .padding()
}
