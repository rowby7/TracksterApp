import SwiftUI
import MapKit
import SwiftData

struct RouteSnapshotView: View {
    let points: [RoutePoint]
    let id: PersistentIdentifier

    @Environment(\.displayScale) private var displayScale
    @State private var image: UIImage?

    private let renderSize = CGSize(width: 480, height: 270)
    private let aspectRatio: CGFloat = 16 / 9

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
            } else {
                Rectangle()
                    .fill(.quaternary)
                    .overlay {
                        ProgressView()
                    }
            }
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
        .task {
            image = await RouteSnapshotter.shared.image(
                for: points,
                id: id,
                size: renderSize,
                scale: displayScale
            )
        }
    }
}

#Preview("Route snapshot") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Run.self, RoutePoint.self, configurations: config)

    let run = Run(startDate: .now, endDate: .now, duration: 100)
    container.mainContext.insert(run)
    run.route = [
        RoutePoint(latitude: 40.7580, longitude: -73.9855, timestamp: .now),
        RoutePoint(latitude: 40.7614, longitude: -73.9776, timestamp: .now.addingTimeInterval(60)),
        RoutePoint(latitude: 40.7644, longitude: -73.9730, timestamp: .now.addingTimeInterval(120)),
        RoutePoint(latitude: 40.7681, longitude: -73.9712, timestamp: .now.addingTimeInterval(180))
    ]

    return RouteSnapshotView(points: run.route, id: run.persistentModelID)
        .padding()
        .modelContainer(container)
}
