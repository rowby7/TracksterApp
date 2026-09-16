# Trackster — Roadmap

> **The app:** a run tracker for iOS. Record a run with a stopwatch, see your route on a
> map, browse your history, and have Apple Watch workouts flow in from HealthKit so
> everything lives in one place.
>
> **Stack:** SwiftUI · SwiftData · HealthKit · CoreLocation · MapKit · iOS 26.5

**How to use this file:** pick the top unchecked box in the current phase. One box ≈ one
sitting. Check it off, commit, move on. Don't skip ahead — each phase assumes the last one.

---

## Where it is today (2026-09-15)

Working:
- Tab shell: Home / History / Profile
- `StopwatchViewModel` — starts, computes elapsed from a `startDate`, formats `mm:ss.SS`
- `RecordingView` — `TimelineView(.periodic)` drives the display, Stop saves + dismisses
- `StopwatchModel` — SwiftData record: start, end, duration, optional `healthKitID`
- `HistoryView` — reverse-chronological cards
- `HealthKitManager` — auth request, workout fetch, de-duped import by UUID

Not there yet:
- No distance. No pace. No GPS. A run tracker that only knows *how long* is half an app.
- Stopwatch can't pause, and loses its run if the app is killed mid-recording
- Profile is one button that vanishes after you tap it
- `Item.swift` is Xcode template leftover, still registered in the schema
- Empty stub files: `HomeModel`, `HomeViewModel`, `HistoryModel`
- History has no empty state, no detail screen, no delete
- Tests are template stubs
- `SWIFT_VERSION = 5.0` — not on Swift 6 language mode yet

---

## Phase 1 — Clean the foundation (2–3 days)

Small wins. Get the house in order before building the extension.

- [x] Delete `Item.swift` and remove `Item.self` from the `Schema` in `TracksterApp.swift`.
      Fix the `#Preview` in `RootTabView` that references it.
- [x] Delete the three empty stub files (`HomeModel`, `HomeViewModel`, `HistoryModel`).
      Add them back only when a file has something to hold.
- [x] Rename `StopwatchModel` → `Run`. It's the app's core record, not a stopwatch.
      (Xcode refactor > rename. Watch for the SwiftData migration — deleting the app
      from the simulator is fine at this stage.)
- [x] Add an empty state to `HistoryView`: `ContentUnavailableView` when `runs.isEmpty`.
- [x] Swipe-to-delete on history rows (`runContext.delete(run)`).
- [ ] Stop swallowing HealthKit errors. `try? await` in `HistoryView.task` hides every
      failure — surface a banner or at least log it.

**Done when:** no template code left, history handles zero runs and lets you remove one.

---

## Phase 2 — Distance and pace (4–6 days) ← *the real feature*

This is what turns it into a running app. Take your time here.

- [ ] Add `NSLocationWhenInUseUsageDescription` + `NSLocationAlwaysAndWhenInUseUsageDescription`
      to build settings, and the `location` background mode capability.
- [ ] Build `LocationManager` (`@Observable`, wraps `CLLocationManager`):
      request auth, `startUpdatingLocation`, `allowsBackgroundLocationUpdates = true`,
      `activityType = .fitness`, `distanceFilter` ~5m.
- [ ] Publish a stream of `CLLocation` into `StopwatchViewModel` — rename it `RunSession`
      while you're at it. Accumulate `totalDistance` by summing `location.distance(from: previous)`.
- [ ] Filter junk points: drop anything with `horizontalAccuracy > 20` or a negative value,
      and drop points older than ~5 seconds (`timestamp` check).
- [ ] Show live distance + current pace on `RecordingView` under the timer.
      Pace = `duration / distanceInMiles` → format as `mm:ss /mi`.
- [ ] Persist the route: new `@Model RoutePoint` (lat, lon, timestamp, optional elevation)
      with a `@Relationship(deleteRule: .cascade)` from `Run`.
- [ ] Store `distance` and `averagePace` on `Run` so History doesn't recompute every row.
- [ ] Add distance + pace to the history card.

**Done when:** you can run around the block, come back, and the app tells you how far you
went and how fast.

---

## Phase 3 — Make a run feel real (3–4 days)

- [ ] Pause / resume. Track `accumulatedTime` plus a current `segmentStart` instead of a
      single `startDate`. Pause also pauses location updates.
- [ ] Crash/kill recovery: write the in-progress run's start time and accumulated time to
      `UserDefaults` (or an `isActive` flag on a `Run`) on every tick. On launch, if one
      exists, offer "Resume run in progress?"
- [ ] Countdown before the run starts — 3 · 2 · 1 · GO. Small thing, feels enormous.
- [ ] Haptics on start, pause, and stop (`UIImpactFeedbackGenerator` / `.sensoryFeedback`).
- [ ] Keep the screen awake while recording (`UIApplication.shared.isIdleTimerDisabled`).
- [ ] Confirmation before discarding a run — right now Stop saves unconditionally.
      Offer Save / Discard.

**Done when:** you'd trust it with a real run and not worry about losing it.

---

## Phase 4 — The map (2–3 days)

Uncomment that `MapCardView` TODO you left in `HistoryView.swift`.

- [ ] `RunDetailView` — tap a history card, push to a full run breakdown.
- [ ] Draw the route with `MapPolyline` over the run's `RoutePoint`s.
- [ ] Auto-frame the map to the route's bounding region.
- [ ] Start/finish markers (green pin, checkered flag).
- [ ] Live map on `RecordingView` — the trail drawing behind you as you run.
- [ ] Per-mile splits list on the detail screen.

**Done when:** you finish a run and immediately want to look at the map.

---

## Phase 5 — Profile & stats (2–3 days)

- [ ] Real `ProfileView`: total runs, total distance, total time, longest run, best pace.
- [ ] Move HealthKit import to a proper Settings row with state
      (not authorized / authorized / last imported at …), instead of a button that vanishes.
- [ ] Weekly + monthly distance totals.
- [ ] A simple bar chart of the last 8 weeks (Swift Charts).
- [ ] Unit preference — miles vs. kilometers — stored in `@AppStorage`, respected everywhere.

**Done when:** opening Profile tells you something you didn't already know.

---

## Phase 6 — Polish & ship (ongoing)

- [ ] Move `SWIFT_VERSION` to 6.0 and fix the concurrency warnings. Run the
      `swift-concurrency-pro` and `swiftui-pro` skills over the codebase.
- [ ] Real tests: `RunSession` pace math, distance accumulation, HealthKit de-duplication.
      The template stubs in `TracksterTests` don't test anything.
- [ ] App icon + accent color (`Assets.xcassets` is still default).
- [ ] Dark mode pass — `.fill(.background)` cards need checking.
- [ ] Dynamic Type + VoiceOver on the recording screen.
- [ ] Live Activity on the Lock Screen during a run.
- [ ] Write runs *back* to HealthKit (currently read-only — `toShare: []`).
- [ ] TestFlight build to a friend.

---

## Parked (decide later, don't build yet)

- watchOS companion app — big lift, changes the architecture. Worth it, but not before Phase 5.
- Goals & training plans
- Social / sharing a run
- Audio cues mid-run ("mile 2, 8:47 pace")
- iCloud sync via SwiftData's CloudKit backing

---

## Daily ritual

1. Open this file.
2. Take the top unchecked box.
3. Build it, run it on the simulator, check the box.
4. `git commit` with a message naming the box.

If a box takes more than two sittings, it was too big — split it in the file.
