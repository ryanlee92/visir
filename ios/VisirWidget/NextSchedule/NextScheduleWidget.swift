import WidgetKit
import SwiftUI

struct NextScheduleWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        NextScheduleMediumWidgetView(entry: entry)
    }
}

@available(iOS 17.0, *)
private struct NextScheduleWidgetBackgroundWrapper: View {
    @Environment(\.colorScheme) var colorScheme
    let entry: Provider.Entry

    var body: some View {
        let colors = VisirColorScheme.getColor(for: colorScheme)
        NextScheduleWidgetEntryView(entry: entry)
            .containerBackground(for: .widget) {
                colors.background
            }
    }
}

struct NextScheduleWidget: Widget {
    let kind: String = "NextScheduleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                NextScheduleWidgetBackgroundWrapper(entry: entry)
            } else {
                NextScheduleWidgetEntryView(entry: entry)
                    .padding()
                    .background(Color.clear)
            }
        }
        .configurationDisplayName("Next Schedule")
        .description("View your next upcoming schedule")
        .supportedFamilies([.systemMedium])
        .disableContentMarginsIfNeeded()
    }
}

