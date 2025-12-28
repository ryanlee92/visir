import WidgetKit
import SwiftUI

struct TodayWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        TodayMediumWidgetView(entry: entry)
    }
}

@available(iOS 17.0, *)
private struct TodayWidgetBackgroundWrapper: View {
    @Environment(\.colorScheme) var colorScheme
    let entry: Provider.Entry

    var body: some View {
        let colors = VisirColorScheme.getColor(for: colorScheme)
        TodayWidgetEntryView(entry: entry)
            .containerBackground(for: .widget) {
                colors.background
            }
    }
}

struct TodayWidget: Widget {
    let kind: String = "TodayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                TodayWidgetBackgroundWrapper(entry: entry)
            } else {
                TodayWidgetEntryView(entry: entry)
                    .padding()
                    .background(Color.clear)
            }
        }
        .configurationDisplayName("Today")
        .description("Quick view of today’s events and tasks")
        .disableContentMarginsIfNeeded()
        .supportedFamilies([.systemMedium])
    }
}