import SwiftUI
import WidgetKit

struct TodayMediumWidgetView: View {
    static let topPadding: CGFloat = 14
    static let horizontalPadding: CGFloat = 12
    var entry: Provider.Entry
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetRenderingMode) var renderingMode

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter
    }()

    private let headerDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = .current
        return formatter
    }()

    private var weekdayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE"
        return formatter.string(from: entry.date).uppercased()
    }

    private var sortedDates: [(String, DateGroupedAppointments)] {
        let localDateFormatter = DateFormatter()
        localDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        localDateFormatter.timeZone = .current
        let today = Calendar.current.startOfDay(for: entry.date)
        return entry.dateGroupedAppointments
            .filter { (key, _) in
                if let date = localDateFormatter.date(from: key) {
                    return date >= today
                }
                return false
            }
            .sorted { (first, second) in
                let firstDate = localDateFormatter.date(from: first.key) ?? Date()
                let secondDate = localDateFormatter.date(from: second.key) ?? Date()
                return firstDate < secondDate
            }
    }

    private var todayString: String {
        dateFormatter.string(from: entry.date) + "T00:00:00.000"
    }

    private var todayData: DateGroupedAppointments? {
        let todayString = dateFormatter.string(from: entry.date) + "T00:00:00.000"
        return entry.dateGroupedAppointments[todayString]
    }
    
    private var allDayEvents: [Appointment] {
        todayData?.appointments.filter { $0.isAllDay } ?? []
    }
    
    private var timedEvents: [Appointment] {
        let now = Date()
        return todayData?.appointments.filter { appointment in
            !appointment.isAllDay && appointment.endAt > now
        } ?? []
    }
    
    private var userEmail: String {
        let defaults = UserDefaults(suiteName: "group.com.wavetogether.fillin")
        return defaults?.string(forKey: "userEmail") ?? ""
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
                HStack(spacing: 12) {
                    VStack(spacing: 6) {
                        DateHeaderView(weekdayString: weekdayString, date: entry.date)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                        TodayAllDayEventView(appointments: allDayEvents)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                    TodayTimedEventView(appointments: timedEvents)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.top, Self.topPadding)
                .padding(.horizontal, Self.horizontalPadding)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(renderingMode.description == "accented" ? AnyShapeStyle(colors.background.opacity(0.1)) : AnyShapeStyle(colors.background))
        .widgetURL(
            URL(
                string:
                    "com.wavetogether.fillin://moveToDate?date=\(dateFormatter.string(from: entry.date))"
            ))
    }
}


private struct DateHeaderView: View {
    let weekdayString: String
    let date: Date
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        let colors = VisirColorScheme.getColor(for: colorScheme)
        VStack(alignment: .leading, spacing: 4) {
            Text(weekdayString)
                .font(.custom("SUITE-Medium", size: 12))
                .foregroundColor(colors.primary)
                .frame(maxHeight: 12, alignment: .leading)
            Text(date.formatted(.dateTime.day()))
                .font(.custom("SUITE-Bold", size: 36))
                .foregroundColor(colors.onBackground)
                .frame(maxHeight: 36, alignment: .leading)
        }
    }
}

private struct TodayAllDayEventView: View {
    let appointments: [Appointment]
    @Environment(\.colorScheme) var colorScheme
    
    private let appointmentHeight: CGFloat = 26
    private let minimumBottomPadding: CGFloat = 8
    
    var body: some View {
        let colors = VisirColorScheme.getColor(for: colorScheme)
        GeometryReader { geometry in
            let availableHeight = geometry.size.height
            let maxVisibleAppointments = max(0, Int((availableHeight - minimumBottomPadding) / appointmentHeight))
            let hiddenAppointmentsCount = max(0, appointments.count - maxVisibleAppointments)
            
            VStack(alignment: .leading, spacing: 0) {
                if appointments.isEmpty {
                    AllDayRow(appointments: appointments, emptyText: "No all-day events")
                } else {
                    ForEach(Array(appointments.prefix(maxVisibleAppointments - (hiddenAppointmentsCount > 0 ? 1 : 0))), id: \.id) { appointment in
                        AppointmentRow(appointment: appointment, isSmallWidget: false, isTaskWidget: false)
                    }
                    if hiddenAppointmentsCount > 0 {
                        Text("+\(hiddenAppointmentsCount + 1) more all-day")
                            .font(.caption)
                            .foregroundColor(colors.surfaceTint)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .padding(.leading, 6)
                            .padding(.trailing, 6)
                            .padding(.vertical, 4)
                            .padding(2)
                    }
                }
            }
        }
    }
}

private struct TodayTimedEventView: View {
    let appointments: [Appointment]
    @Environment(\.colorScheme) var colorScheme
    
    private let appointmentHeight: CGFloat = 42
    private let minimumBottomPadding: CGFloat = 8
    
    var body: some View {
        let colors = VisirColorScheme.getColor(for: colorScheme)
        GeometryReader { geometry in
            let availableHeight = geometry.size.height
            let maxVisibleAppointments = max(0, Int((availableHeight - minimumBottomPadding) / appointmentHeight))
            
            VStack(alignment: .leading, spacing: 0) {
                if appointments.isEmpty {
                    AllDayRow(appointments: appointments, emptyText: "No timed events")
                } else {
                    ForEach(Array(appointments.prefix(maxVisibleAppointments)), id: \.id) { appointment in
                        AppointmentRow(appointment: appointment, isSmallWidget: false, isTaskWidget: false)
                    }
                }
            }
        }
    }
}