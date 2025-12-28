//
//  VisirWidgetLiveActivity.swift
//  VisirWidget
//
//  Created by Inseong Song on 4/18/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct VisirWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct VisirWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: VisirWidgetAttributes.self) { context in
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

extension VisirWidgetAttributes {
    fileprivate static var preview: VisirWidgetAttributes {
        VisirWidgetAttributes(name: "World")
    }
}

extension VisirWidgetAttributes.ContentState {
    fileprivate static var smiley: VisirWidgetAttributes.ContentState {
        VisirWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: VisirWidgetAttributes.ContentState {
         VisirWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: VisirWidgetAttributes.preview) {
   VisirWidgetLiveActivity()
} contentStates: {
    VisirWidgetAttributes.ContentState.smiley
    VisirWidgetAttributes.ContentState.starEyes
}
