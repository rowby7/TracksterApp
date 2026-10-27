//
//  RunDetailHeaderView.swift
//  Trackster
//

import SwiftUI

/// Where the run came from, its name, and when it happened.
struct RunDetailHeaderView: View {
    let run: Run

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(run.isImported ? "Apple Watch" : "Trackster",
                  systemImage: run.isImported ? "applewatch" : "iphone")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.fill.tertiary, in: .capsule)

            Text(run.titleText)
                .font(.largeTitle.bold())
                .fontDesign(.rounded)

            Text(run.startDetailText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
