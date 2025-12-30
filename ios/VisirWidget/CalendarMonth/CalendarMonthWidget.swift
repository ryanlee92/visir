import WidgetKit
import SwiftUI

struct CalendarMonthWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        CalendarMonthWidgetView(entry: entry)
    }
}

@available(iOS 17.0, *)
private struct CalendarMonthWidgetBackgroundWrapper: View {
    @Environment(\.colorScheme) var colorScheme
    let entry: Provider.Entry

    var body: some View {
        let colors = VisirColorScheme.getColor(for: colorScheme)
        CalendarMonthWidgetEntryView(entry: entry)
            .containerBackground(for: .widget) {
                colors.background
            }
    }
}

struct CalendarMonthWidget: Widget {
    let kind: String = "CalendarMonthWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                CalendarMonthWidgetBackgroundWrapper(entry: entry)
            } else {
                CalendarMonthWidgetEntryView(entry: entry)
                    .padding()
                    .background(Color.clear)
            }
        }
        .configurationDisplayName("Calendar Month")
        .description("View your calendar in month view")
        .disableContentMarginsIfNeeded()
        .supportedFamilies([.systemLarge])
    }
}

