//
//  RecordingView.swift
//  Trackster
//
//  Created by Rowby Villanueva on 9/11/26.
//

import SwiftUI
import SwiftData

struct RecordingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var stopwatch = StopwatchViewModel()

    var body: some View {
        VStack {
            if let start = stopwatch.startDate {
                TimelineView(.periodic(from: start, by: 0.03)) { context in
                    Text(stopwatch.formattedElapsed(at: context.date))
                        .font(.largeTitle)
                }
            } else {
                Text("00:00")
                    .font(.largeTitle)
            }

            Spacer()

            Button("Stop Recording", systemImage: "stop", action: stopRecording)
                .labelStyle(.iconOnly)
                .font(.largeTitle.scaled(by: 2))
        }
        .padding(.vertical, 150)
        .onAppear {
            stopwatch.start()
        }
    }

    private func stopRecording() {
        stopwatch.stopAndSave(to: modelContext)
        dismiss()
    }
}



#Preview {
    RecordingView()
}
