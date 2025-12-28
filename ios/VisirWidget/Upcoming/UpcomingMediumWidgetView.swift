import SwiftUI
import WidgetKit

struct UpcomingMediumWidgetView: View {
    static let headerHeight: CGFloat = 26  // 8 + 4 + 14 (padding + text height)
    static let allDayRowHeight: CGFloat = 26  // 22 + 2 + 2
    static let appointmentRowHeight: CGFloat = 42  // 38 + 2 + 2
    static let topPadding: CGFloat = 14
    var entry: Provider.Entry
    var isLargeWidget: Bool
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
                HStack(spacing: 0) {
                    DateHeaderView(weekdayString: weekdayString, date: entry.date)
                        .frame(maxHeight: .infinity, alignment: .topLeading)
                        .padding(.trailing, 21)
                        .padding(.leading, 14)

                    AppointmentListView(
                        sortedDates: sortedDates,
                        todayString: todayString,
                        availableHeight: geometry.size.height - Self.topPadding,
                        dateFormatter: dateFormatter,
                        headerDateFormatter: headerDateFormatter,
                        isLargeWidget: isLargeWidget
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.trailing, 12)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.top, Self.topPadding)
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

private struct AppointmentListView: View {
    let sortedDates: [(String, DateGroupedAppointments)]
    let todayString: String
    let availableHeight: CGFloat
    let dateFormatter: DateFormatter
    let headerDateFormatter: DateFormatter
    let isLargeWidget: Bool
    @Environment(\.colorScheme) var colorScheme

    private func calculateSectionHeight(dateString: String, appointments: DateGroupedAppointments)
        -> CGFloat
    {
        var height: CGFloat = 0

        // Add header height if not today
        if dateString != todayString {
            height += UpcomingMediumWidgetView.headerHeight
        }

        // Add all-day appointments height
        if isLargeWidget {
            let allDayCount = appointments.activeAppointments.filter { $0.isAllDay }.count
            if allDayCount > 0 {
                height += CGFloat(allDayCount) * UpcomingMediumWidgetView.allDayRowHeight
            } else {
                height += UpcomingMediumWidgetView.allDayRowHeight
            }
        } else {
            height += UpcomingMediumWidgetView.allDayRowHeight
        }

        // Add non-all-day appointments height
        let nonAllDayCount = appointments.activeAppointments.filter { !$0.isAllDay }.count
        height += CGFloat(nonAllDayCount) * UpcomingMediumWidgetView.appointmentRowHeight

        return height
    }

    var body: some View {
        let colors = VisirColorScheme.getColor(for: colorScheme)
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(sortedDates.enumerated()), id: \.element.0) { index, dateGroup in
                let (dateString, appointments) = dateGroup
                let previousSectionsHeight = sortedDates.prefix(index).reduce(0) { sum, dateGroup in
                    sum + calculateSectionHeight(dateString: dateGroup.0, appointments: dateGroup.1)
                }
                let sectionAvailableHeight = availableHeight - previousSectionsHeight

                if sectionAvailableHeight > 0 {
                    AppointmentSectionView(
                        dateString: dateString,
                        appointments: appointments,
                        todayString: todayString,
                        sectionAvailableHeight: sectionAvailableHeight,
                        dateFormatter: dateFormatter,
                        headerDateFormatter: headerDateFormatter,
                        isLargeWidget: isLargeWidget
                    )
                }
            }
        }
    }
}

private struct AppointmentSectionView: View {
    let dateString: String
    let appointments: DateGroupedAppointments
    let todayString: String
    let sectionAvailableHeight: CGFloat
    let dateFormatter: DateFormatter
    let headerDateFormatter: DateFormatter
    let isLargeWidget: Bool
    @Environment(\.colorScheme) var colorScheme

    private var maxVisibleAppointments: Int {
        var availableHeight = sectionAvailableHeight

        // Subtract header height if not today
        if dateString != todayString {
            availableHeight -= UpcomingMediumWidgetView.headerHeight
        }

        // Subtract all-day row height or individual all-day appointments height
        if isLargeWidget {
            let allDayCount = appointments.activeAppointments.filter { $0.isAllDay }.count
            if allDayCount > 0 {
                availableHeight -= CGFloat(allDayCount) * UpcomingMediumWidgetView.allDayRowHeight
            } else {
                availableHeight -= UpcomingMediumWidgetView.allDayRowHeight
            }
        } else {
            availableHeight -= UpcomingMediumWidgetView.allDayRowHeight
        }

        // Calculate how many appointments can fit
        return max(0, Int(availableHeight / UpcomingMediumWidgetView.appointmentRowHeight))
    }

    private var nonAllDayAppointments: [Appointment] {
        appointments.activeAppointments.filter { !$0.isAllDay }
    }

    private var allDayAppointments: [Appointment] {
        appointments.activeAppointments.filter { $0.isAllDay }
    }

    private var hiddenAppointmentsCount: Int {
        max(0, nonAllDayAppointments.count - maxVisibleAppointments)
    }

    private var canShowMoreText: Bool {
        var remainingHeight = sectionAvailableHeight

        // Subtract header height if not today
        if dateString != todayString {
            remainingHeight -= UpcomingMediumWidgetView.headerHeight
        }

        // Subtract all-day row height or individual all-day appointments height
        if isLargeWidget {
            let allDayCount = appointments.activeAppointments.filter { $0.isAllDay }.count
            remainingHeight -= CGFloat(allDayCount) * UpcomingMediumWidgetView.allDayRowHeight
        } else {
            remainingHeight -= UpcomingMediumWidgetView.allDayRowHeight
        }

        // Subtract height used by visible appointments
        remainingHeight -=
            CGFloat(maxVisibleAppointments) * UpcomingMediumWidgetView.appointmentRowHeight

        // Check if we have enough height for "more" text (28 points)
        return remainingHeight >= 28
    }

    var body: some View {
        let colors = VisirColorScheme.getColor(for: colorScheme)
        VStack(alignment: .leading, spacing: 0) {
            // Header
            if dateString != todayString,
                let date = dateFormatter.date(from: String(dateString.prefix(10))),
                sectionAvailableHeight >= UpcomingMediumWidgetView.headerHeight + 6
            {
                Text(headerDateFormatter.string(from: date))
                    .font(.custom("SUITE-Medium", size: 12))
                    .foregroundColor(colors.onBackground)
                    .frame(height: 14)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                    .padding(.leading, 8)
            }

            // All-day row
            if sectionAvailableHeight >= UpcomingMediumWidgetView.headerHeight
                + UpcomingMediumWidgetView.allDayRowHeight + 6
            {
                if isLargeWidget {
                    if allDayAppointments.isEmpty {
                        AllDayRow(appointments: [], emptyText: nil)
                    } else {
                        ForEach(allDayAppointments, id: \.id) { appointment in
                            AppointmentRow(appointment: appointment, isSmallWidget: false, isTaskWidget: false)
                        }
                    }
                } else {
                    if (appointments.eventAlldayCount + appointments.taskAlldayCount) == 1 {
                        if let firstAllDayAppointment = appointments.activeAppointments.first(where: {
                            $0.isAllDay
                        }) {
                            AppointmentRow(appointment: firstAllDayAppointment, isSmallWidget: false, isTaskWidget: false)
                        }
                    } else {
                        AllDayRow(appointments: allDayAppointments, emptyText: nil)
                    }
                }
            }

            // Non-all-day appointments
            ForEach(Array(nonAllDayAppointments.prefix(maxVisibleAppointments)), id: \.id) {
                appointment in
                AppointmentRow(appointment: appointment, isSmallWidget: false, isTaskWidget: false)
            }

            if hiddenAppointmentsCount > 0 && canShowMoreText {
                Text("+\(hiddenAppointmentsCount) more")
                    .font(.system(size: 12))
                    .frame(height: 14)
                    .foregroundColor(colors.surfaceTint)
                    .padding(.leading, 7)
                    .padding(.top, 4)
            }
        }
    }
}
