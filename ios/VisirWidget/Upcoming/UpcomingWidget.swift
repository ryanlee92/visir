import WidgetKit
import SwiftUI

struct UpcomingWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            UpcomingSmallWidgetView(entry: entry)
        case .systemMedium:
            UpcomingMediumWidgetView(entry: entry, isLargeWidget: false)
        case .systemLarge:
            UpcomingMediumWidgetView(entry: entry, isLargeWidget: true)
        default:
            Text("Unsupported widget size")
        }
    }
}

@available(iOS 17.0, *)
private struct UpcomingWidgetBackgroundWrapper: View {
    @Environment(\.colorScheme) var colorScheme
    let entry: Provider.Entry

    var body: some View {
        let colors = VisirColorScheme.getColor(for: colorScheme)
        UpcomingWidgetEntryView(entry: entry)
            .containerBackground(for: .widget) {
                colors.background
            }
    }
}

struct UpcomingWidget: Widget {
    let kind: String = "UpcomingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                UpcomingWidgetBackgroundWrapper(entry: entry)
            } else {
                UpcomingWidgetEntryView(entry: entry)
                    .padding()
                    .background(Color.clear)
            }
        }
        .configurationDisplayName("Upcoming")
        .description("View your upcoming events and tasks")
        .disableContentMarginsIfNeeded()
    }
}

extension WidgetConfiguration {
    func disableContentMarginsIfNeeded() -> some WidgetConfiguration {
        if #available(iOSApplicationExtension 17.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }
}