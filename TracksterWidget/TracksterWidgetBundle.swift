//
//  TracksterWidgetBundle.swift
//  TracksterWidget
//
//  Created by Rowby Villanueva on 10/23/26.
//

import WidgetKit
import SwiftUI

@main
struct TracksterWidgetBundle: WidgetBundle {
    var body: some Widget {
        TracksterWidget()
        TracksterWidgetControl()
        TracksterWidgetLiveActivity()
    }
}
