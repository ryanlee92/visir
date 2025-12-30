import SwiftUI
import WidgetKit

struct CalendarMonthWidgetView: View {
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

    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = .current
        return formatter
    }()
    
    private let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = .current
        return formatter
    }()

    private let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        return formatter
    }()
    
    private var weekdayLabels: [String] {
        // Sunday = 1, Monday = 2, ..., Saturday = 7
        let calendar = Calendar.current
        var labels: [String] = []
        // Create a date for Sunday of current week
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysFromSunday = (weekday - calendar.firstWeekday + 7) % 7
        if let sunday = calendar.date(byAdding: .day, value: -daysFromSunday, to: today) {
            for i in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: i, to: sunday) {
                    let label = weekdayFormatter.string(from: date).uppercased()
                    labels.append(label)
                }
            }
        }
        return labels
    }

    private var userEmail: String {
        let defaults = UserDefaults(suiteName: "group.com.wavetogether.fillin")
        return defaults?.string(forKey: "userEmail") ?? ""
    }

    private var currentMonth: Date {
        Calendar.current.startOfDay(for: entry.date)
    }

    private var calendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = 1 // Sunday = 1
        return cal
    }

    private var monthDays: [Date] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysInMonth = calendar.range(of: .day, in: .month, for: startOfMonth)!.count
        
        var days: [Date] = []
        
        // Add days from previous month
        let daysToAdd = (firstWeekday - calendar.firstWeekday + 7) % 7
        if daysToAdd > 0 {
            let prevMonth = calendar.date(byAdding: .month, value: -1, to: startOfMonth)!
            let daysInPrevMonth = calendar.range(of: .day, in: .month, for: prevMonth)!.count
            // Add days starting from (daysInPrevMonth - daysToAdd + 1) to daysInPrevMonth
            for day in (daysInPrevMonth - daysToAdd + 1)...daysInPrevMonth {
                var components = calendar.dateComponents([.year, .month], from: prevMonth)
                components.day = day
                if let date = calendar.date(from: components) {
                    days.append(date)
                }
            }
        }
        
        // Add days from current month
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        // Add days from next month to fill the grid (6 weeks = 42 days)
        let remainingDays = 42 - days.count
        if remainingDays > 0 {
            let nextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
            for day in 1...remainingDays {
                if let date = calendar.date(byAdding: .day, value: day - 1, to: nextMonth) {
                    days.append(date)
                }
            }
        }
        
        return days
    }

    private func appointmentsForDate(_ date: Date) -> [Appointment] {
        let dateString = dateFormatter.string(from: date) + "T00:00:00.000"
        return entry.dateGroupedAppointments[dateString]?.appointments.filter { !$0.isDone } ?? []
    }

    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    private func isCurrentMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
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
                    // Month header
                    HStack {
                        HStack(spacing: 4) {
                            Text(monthFormatter.string(from: currentMonth))
                                .font(.custom("SUITE-Bold", size: 16))
                                .foregroundColor(colors.onBackground)
                            Text(yearFormatter.string(from: currentMonth))
                                .font(.custom("SUITE-Bold", size: 16))
                                .foregroundColor(colors.primary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, Self.horizontalPadding)
                    .padding(.top, Self.topPadding)
                    .padding(.bottom, 4)

                    // Weekday headers
                    HStack(spacing: 0) {
                        ForEach(Array(weekdayLabels.enumerated()), id: \.offset) { index, weekday in
                            Text(weekday)
                                .font(.custom("SUITE-Bold", size: 10))
                                .foregroundColor(index == 0 ? colors.error : (index == 6 ? colors.tertiary : colors.onBackground))
                                .frame(maxWidth: .infinity)
                                .overlay(
                                    Rectangle()
                                        .stroke(colors.outline.opacity(0.2), lineWidth: 0.5)
                                )
                        }
                    }
                    .padding(.bottom, 4)

                    // Calendar grid
                    GeometryReader { gridGeometry in
                        let cellWidth = gridGeometry.size.width / 7
                        let cellHeight = gridGeometry.size.height / 6
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
                            ForEach(monthDays, id: \.self) { date in
                                CalendarDayCell(
                                    date: date,
                                    appointments: appointmentsForDate(date),
                                    isToday: isToday(date),
                                    isCurrentMonth: isCurrentMonth(date),
                                    cellWidth: cellWidth,
                                    cellHeight: cellHeight
                                )
                            }
                        }
                    }
                    .overlay(
                        // Add subtle borders between cells
                        GeometryReader { gridGeometry in
                            Path { path in
                                let cellWidth = gridGeometry.size.width / 7
                                let cellHeight = gridGeometry.size.height / 6
                                
                                // Vertical lines
                                for i in 1..<7 {
                                    let x = CGFloat(i) * cellWidth
                                    path.move(to: CGPoint(x: x, y: 0))
                                    path.addLine(to: CGPoint(x: x, y: gridGeometry.size.height))
                                }
                                
                                // Horizontal lines
                                for i in 1..<6 {
                                    let y = CGFloat(i) * cellHeight
                                    path.move(to: CGPoint(x: 0, y: y))
                                    path.addLine(to: CGPoint(x: gridGeometry.size.width, y: y))
                                }
                            }
                            .stroke(colors.outline.opacity(0.2), lineWidth: 0.5)
                        }
                    )
                }
                .padding(.bottom, 2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(renderingMode.description == "accented" ? AnyShapeStyle(colors.background.opacity(0.1)) : AnyShapeStyle(colors.background))
        .widgetURL(
            URL(
                string: "com.wavetogether.fillin://moveToDate?date=\(dateFormatter.string(from: currentMonth))"
            ))
    }
}

struct CalendarDayCell: View {
    let date: Date
    let appointments: [Appointment]
    let isToday: Bool
    let isCurrentMonth: Bool
    let cellWidth: CGFloat
    let cellHeight: CGFloat
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetRenderingMode) var renderingMode

    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        formatter.timeZone = .current
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter
    }()

    var body: some View {
        let colors = VisirColorScheme.getColor(for: colorScheme)
        let dayNumber = Int(dayFormatter.string(from: date)) ?? 0
        
        VStack(alignment: .leading, spacing: 1) {
            // Day number
            Text("\(dayNumber)")
                .font(.custom("SUITE-Medium", size: 11))
                .foregroundColor(isToday ? colors.secondary : (isCurrentMonth ? colors.onBackground : colors.surfaceTint))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 4)
                .padding(.trailing, 2)
                .padding(.top, 1)
            
            // Show appointment boxes
            if !appointments.isEmpty {
                VStack(alignment: .leading, spacing: 1) {
                    // Calculate max visible appointments more accurately
                    // Day number takes ~13 points (11pt font + 2pt padding)
                    // Each event box is ~8 points (7pt font + 1.5pt padding * 2)
                    let dayNumberHeight: CGFloat = 13
                    let eventBoxHeight: CGFloat = 8
                    let availableHeight = cellHeight - dayNumberHeight - 2 // 2pt for spacing
                    let maxVisible = max(0, min(appointments.count, Int(availableHeight / eventBoxHeight)))
                    
                    ForEach(Array(appointments.prefix(maxVisible)), id: \.id) { appointment in
                        CalendarEventBox(appointment: appointment)
                    }
                    if appointments.count > maxVisible {
                        Text("...")
                            .font(.system(size: 7))
                            .foregroundColor(colors.surfaceTint)
                            .padding(.horizontal, 2)
                            .padding(.vertical, 1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer(minLength: 0)
        }
        .frame(width: cellWidth, height: cellHeight, alignment: .topLeading)
        .clipped() // Clip content that exceeds cell boundaries
        .background(
            RoundedRectangle(cornerRadius: 2)
                .fill(isToday ? colors.secondary.opacity(0.1) : Color.clear)
        )
        .overlay(
            Rectangle()
                .stroke(colors.outline.opacity(0.2), lineWidth: 0.5)
        )
        .overlay(
            Button(
                intent: OpenAppIntent(
                    url: URL(string: "com.wavetogether.fillin://moveToDate?date=\(dateFormatter.string(from: date))"),
                    appGroup: "group.com.wavetogether.fillin"
                )
            ) {
                Rectangle()
                    .fill(Color.clear)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .buttonStyle(.plain)
        )
    }
}

struct CalendarEventBox: View {
    let appointment: Appointment
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetRenderingMode) var renderingMode
    
    var body: some View {
        let colors = VisirColorScheme.getColor(for: colorScheme)
        
        Text(appointment.title)
            .font(.system(size: 7, weight: .medium))
            .foregroundColor(appointment.textColor(isDarkMode: colors.isDarkMode))
            .lineLimit(1)
            .truncationMode(.tail)
            .padding(.horizontal, 3)
            .padding(.vertical, 1.5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 2)
                    .fill(renderingMode.description == "accented" 
                          ? AnyShapeStyle(appointment.backgroundColor(isDarkMode: colors.isDarkMode).opacity(0.1))
                          : AnyShapeStyle(appointment.backgroundColor(isDarkMode: colors.isDarkMode)))
            )
            .padding(.horizontal, 1)
    }
}

