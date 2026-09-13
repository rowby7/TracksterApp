//
//  AppTitleModifier.swift
//  Trackster
//
//  Created by Rowby Villanueva on 9/13/26.
//

import SwiftUI

struct AppTitleModifier: ViewModifier {
    let title: String

    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.headline)
                }
            }
    }
}

extension View {
    func appTitle(_ title: String = "Trackster") -> some View {
        modifier(AppTitleModifier(title: title))
    }
}

