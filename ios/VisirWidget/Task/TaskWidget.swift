import WidgetKit
import SwiftUI

struct TaskWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            TaskSmallWidgetView(entry: entry)
        case .systemMedium:
            TaskMediumWidgetView(entry: entry)
        case .systemLarge:
            TaskMediumWidgetView(entry: entry)
        default:
            Text("Unsupported widget size")
        }
    }
}

@available(iOS 17.0, *)
private struct TaskWidgetBackgroundWrapper: View {
    @Environment(\.colorScheme) var colorScheme
    let entry: Provider.Entry

    var body: some View {
        let colors = VisirColorScheme.getColor(for: colorScheme)
        TaskWidgetEntryView(entry: entry)
            .containerBackground(for: .widget) {
                colors.background
            }
    }
}

struct TaskWidget: Widget {
    let kind: String = "TaskWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                TaskWidgetBackgroundWrapper(entry: entry)
            } else {
                TaskWidgetEntryView(entry: entry)
                    .padding()
                    .background(Color.clear)
            }
        }
        .configurationDisplayName("Task")
        .description("View your upcoming tasks")
        .disableContentMarginsIfNeeded()
    }
}