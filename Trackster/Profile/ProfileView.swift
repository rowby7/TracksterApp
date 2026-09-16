//
//  ProfileVIew.swift
//  Trackster
//
//  Created by Rowby Villanueva on 9/13/26.
//

import SwiftUI

struct ProfileView: View {
    @AppStorage("hasRequestedHealthAccess") private var hasRequestedHealthAccess = false
    @State private var healthKitManager = HealthKitManager()

    var body: some View {
        NavigationStack {
            if !hasRequestedHealthAccess {
                Button("Import Fitness Data", action: importFitnessData)
            }
        }
        .appTitle()
    }

    private func importFitnessData() {
        Task {
            try? await healthKitManager.requestAuthorization()
            hasRequestedHealthAccess = true
        }
    }
}

#Preview {
    ProfileView()
}
