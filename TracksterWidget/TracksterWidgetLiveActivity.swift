//
//  TracksterWidgetLiveActivity.swift
//  TracksterWidget
//
//  Created by Rowby Villanueva on 10/23/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TracksterWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct TracksterWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TracksterWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension TracksterWidgetAttributes {
    fileprivate static var preview: TracksterWidgetAttributes {
        TracksterWidgetAttributes(name: "World")
    }
}

extension TracksterWidgetAttributes.ContentState {
    fileprivate static var smiley: TracksterWidgetAttributes.ContentState {
        TracksterWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: TracksterWidgetAttributes.ContentState {
         TracksterWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: TracksterWidgetAttributes.preview) {
   TracksterWidgetLiveActivity()
} contentStates: {
    TracksterWidgetAttributes.ContentState.smiley
    TracksterWidgetAttributes.ContentState.starEyes
}
