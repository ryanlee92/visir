import SwiftUI
import WidgetKit

struct TaskSmallWidgetView: View {
    var entry: Provider.Entry
    @State private var taskRowHeight: CGFloat = 0
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetRenderingMode) var renderingMode
    
    private static let weekdayTextHeight: CGFloat = 12
    private static let weekdayTextPadding: CGFloat = 1
    private static let dateTextHeight: CGFloat = 30
    private static let dateTextPadding: CGFloat = 2
    private static let appointmentRowHeight: CGFloat = 26
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter
    }()
    
    private var todayData: DateGroupedAppointments? {
        let todayString = dateFormatter.string(from: entry.date) + "T00:00:00.000"
        return entry.dateGroupedAppointments[todayString]
    }
    
    private var userEmail: String {
        let defaults = UserDefaults(suiteName: "group.com.wavetogether.fillin")
        return defaults?.string(forKey: "userEmail") ?? ""
    }
    
    private func calculateMaxRows(totalHeight: CGFloat) -> Int {
        let availableHeight = totalHeight - (Self.weekdayTextHeight + Self.weekdayTextPadding * 2 + Self.dateTextHeight + Self.dateTextPadding * 2) - 8
        return Int(availableHeight / Self.appointmentRowHeight)
    }
    
    var body: some View {
        let colors = VisirColorScheme.getColor(for: colorScheme)
        GeometryReader { geometry in
            if userEmail.isEmpty {
                Text("Please login")
                    .font(.headline)
                    .foregroundColor(colors.onBackground)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                VStack(spacing: 0) {
                    Text(entry.date.formatted(.dateTime.weekday(.wide)))
                        .font(.custom("SUITE-Medium", size: 12))
                        .foregroundColor(colors.primary)
                        .frame(maxWidth: .infinity, maxHeight: Self.weekdayTextHeight, alignment: .leading)
                        .padding(Self.weekdayTextPadding)
                    Text(entry.date.formatted(.dateTime.day()))
                        .font(.custom("SUITE-Bold", size: 30))
                        .foregroundColor(colors.onBackground)
                        .frame(maxWidth: .infinity, maxHeight: Self.dateTextHeight, alignment: .leading)
                        .padding(Self.dateTextPadding)
                    Spacer()
                    if let todayData = todayData {
                        let tasks = todayData.activeAppointments.filter { !$0.isEvent }
                        if tasks.isEmpty {
                            AllDayRow(
                                appointments: [],
                                emptyText: "No tasks"
                            )
                        } else {
                            ForEach(Array(tasks.prefix(calculateMaxRows(totalHeight: geometry.size.height))), id: \.id) { taskAppointment in
                                AppointmentRow(appointment: taskAppointment, isSmallWidget: true, isTaskWidget: true)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(12)
        .background(renderingMode.description == "accented" ? AnyShapeStyle(colors.background.opacity(0.1)) : AnyShapeStyle(colors.background))
        .widgetURL(URL(string: "com.wavetogether.fillin://moveToDate?date=\(dateFormatter.string(from: entry.date))"))
    }
} 