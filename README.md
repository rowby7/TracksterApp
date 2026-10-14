# Trackster

A run tracker for iOS. Record a run with live GPS, see your route on a map, and have your Apple Watch runs flow in from HealthKit so everything lives in one place.

> **Status:** in active development. See [ROADMAP.md](ROADMAP.md) for what's done and what's next.

<!-- Screenshots: run the app in the Simulator, press Cmd+S on each screen,
     put the images in a /Screenshots folder, then uncomment this table.

| History | Recording | Route |
| :---: | :---: | :---: |
| <img src="Screenshots/history.png" width="220"> | <img src="Screenshots/recording.png" width="220"> | <img src="Screenshots/route.png" width="220"> |
-->

## Features

- **Live run recording.** Timer, distance, and current pace (min/mi) update as you run, using the phone's own GPS. No Watch needed.
- **Keeps recording in the background.** Tracking continues when the screen locks.
- **Apple Watch import.** Pulls running and walking workouts from HealthKit, including route, distance, heart rate, calories, and elevation.
- **One run history.** App-recorded and imported runs share the same data model, shown newest first, with swipe to delete.
- **Route thumbnails.** Each history card shows the run's route drawn over a real map.
- **Elevation.** Elevation gain and max elevation for every run that has altitude data.

## Tech stack

| | |
| --- | --- |
| **UI** | SwiftUI |
| **Persistence** | SwiftData |
| **Health data** | HealthKit |
| **Location** | CoreLocation |
| **Maps** | MapKit |
| **Concurrency** | Swift Concurrency (async/await, actors) |
| **Target** | iOS 26.5+ |

## How it works

A few design decisions worth calling out:

- **Location as an async stream.** `RunViewModel` reads GPS from `CLLocationUpdate.liveUpdates(.fitness)` inside a `Task`, so starting a run starts location and stopping a run cancels it. A `CLBackgroundActivitySession` keeps updates coming while the screen is locked.
- **Filtering GPS noise.** Points with a horizontal accuracy worse than 20 m, or older than 5 seconds, are dropped before they count toward distance.
- **Background HealthKit import.** `RunImporter` is a SwiftData `@ModelActor`, so imports run off the main thread. Workouts are de-duplicated by their HealthKit UUID, so re-importing never creates copies.
- **Route queries.** `HKWorkoutRouteQuery` delivers locations in batches; the importer collects them until the query reports it's done, then saves them as `RoutePoint` models linked to the run with a cascade delete.
- **Map thumbnails without live maps.** Putting a live `Map` in every list row would load map tiles for each row while scrolling. Instead, `RouteSnapshotter` renders each route once with `MKMapSnapshotter`, draws the polyline on top, and caches the image with `NSCache`.

## Project structure

```
Trackster/
├── History/      Run history list, run cards, route thumbnails
├── Record/       Start screen, active run screen, live map, Run + RoutePoint models
├── Managers/     HealthKit access, run importer, route snapshotter
├── Profile/      Profile tab (in progress)
├── Extensions/   HKWorkout metrics, map region fitting
└── Modifiers/    Shared view modifiers
```

## Running it

1. Clone the repo and open `Trackster.xcodeproj` in Xcode.
2. Select an iPhone running iOS 26.5 or later.
3. Build and run.

HealthKit import and real GPS work best on a physical iPhone. In the Simulator, use **Features > Location** to simulate a run.

## Roadmap

Up next: a full-screen live map during runs, pause/resume, recovery if the app is closed mid-run, a run detail screen with splits, and profile stats. Full plan in [ROADMAP.md](ROADMAP.md).
