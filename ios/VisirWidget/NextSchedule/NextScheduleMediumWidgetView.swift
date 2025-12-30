import SwiftUI
import WidgetKit

struct NextScheduleMediumWidgetView: View {
    var entry: Provider.Entry
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetRenderingMode) var renderingMode

    private var userEmail: String {
        let defaults = UserDefaults(suiteName: "group.com.wavetogether.fillin")
        return defaults?.string(forKey: "userEmail") ?? ""
    }

    private var nextScheduleData: NextScheduleData? {
        let defaults = UserDefaults(suiteName: "group.com.wavetogether.fillin")
        guard let jsonString = defaults?.string(forKey: "nextSchedule"),
              !jsonString.isEmpty,
              let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(NextScheduleData.self, from: jsonData)
        } catch {
            return nil
        }
    }

    var body: some View {
        let colors = VisirColorScheme.getColor(for: colorScheme)
        GeometryReader { geometry in
            if userEmail.isEmpty {
                Text("Please login")
                    .font(.custom("SUITE-Medium", size: 14))
                    .foregroundColor(colors.onBackground)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else if let data = nextScheduleData {
                NextScheduleContentView(data: data, availableHeight: geometry.size.height, colors: colors)
            } else {
                Text("No upcoming schedule")
                    .font(.custom("SUITE-Medium", size: 14))
                    .foregroundColor(colors.onBackground)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(renderingMode.description == "accented" ? AnyShapeStyle(colors.background.opacity(0.1)) : AnyShapeStyle(colors.background))
        .widgetURL(URL(string: "com.wavetogether.fillin://moveToDate?date=\(dateFormatter.string(from: entry.date))"))
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}



