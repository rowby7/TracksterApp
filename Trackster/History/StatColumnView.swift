//
//  StatColumnView.swift
//  Trackster
//
//  Created by Rowby Villanueva on 9/11/26.
//

import SwiftUI

struct StatColumnView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
            Text(value)
                .font(.title2)
        }
    }
}

#Preview {
    StatColumnView(title: "Distance", value: "1.97 mi")
}
