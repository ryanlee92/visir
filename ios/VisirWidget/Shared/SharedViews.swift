import SwiftUI
import WidgetKit

struct AllDayRow : View {
    let appointments: [Appointment]
    let emptyText: String?
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetRenderingMode) var renderingMode
    
    private var eventCount: Int {
        appointments.filter { $0.isEvent }.count
    }
    
    private var taskCount: Int {
        appointments.filter { !$0.isEvent }.count
    }
    
    private var combinedText: String {
        if appointments.isEmpty {
            return emptyText ?? "No all-day events"
        }
        
        if appointments.count == 1 {
            return appointments[0].title
        }
        
        if appointments.count == 2 {
            return "\(appointments[0].title), \(appointments[1].title)"
        }
        
        // 3개 이상일 경우
        return "\(appointments[0].title), \(appointments[1].title), +\(appointments.count - 2) more"
    }
    
    private var backgroundColor: Color {
        let colors = VisirColorScheme.getColor(for: colorScheme)
        if appointments.isEmpty {
            return colors.outline
        }
        
        // 모든 약속의 색상이 같은지 확인
        let firstColor = appointments[0].backgroundColor(isDarkMode: colors.isDarkMode)
        let allSameColor = appointments.allSatisfy { appointment in
            appointment.backgroundColor(isDarkMode: colors.isDarkMode) == firstColor
        }
        
        return allSameColor ? firstColor : colors.outline
    }
    
    private var textColor: Color {
        let colors = VisirColorScheme.getColor(for: colorScheme)
        if appointments.isEmpty {
            return colors.shadow
        }
        
        // 모든 약속의 텍스트 색상이 같은지 확인
        let firstColor = appointments[0].textColor(isDarkMode: colors.isDarkMode)
        let allSameColor = appointments.allSatisfy { appointment in
            appointment.textColor(isDarkMode: colors.isDarkMode) == firstColor
        }
        
        return allSameColor ? firstColor : colors.shadow
    }
    
    var body: some View {
        let colors = VisirColorScheme.getColor(for: colorScheme)
        Text(combinedText)
            .font(.caption)
            .foregroundColor(textColor)
            .lineLimit(1)
            .truncationMode(.tail)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .opacity(0.9)
            .padding(.leading, 6)
            .padding(.trailing, 6)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(renderingMode.description == "accented" ? AnyShapeStyle(backgroundColor.opacity(0.1)) : AnyShapeStyle(backgroundColor))
            )
            .padding(2)
    }
}

struct AppointmentCheckButton: View {
    let appointment: Appointment
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetRenderingMode) var renderingMode
    
    var body: some View {
        let colors = VisirColorScheme.getColor(for: colorScheme)
        Rectangle()
            .foregroundColor(.clear)
            .frame(width: 12, height: 12)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .inset(by: 0.5)
                    .stroke(renderingMode.description == "accented" ? AnyShapeStyle(appointment.foregroundColor(isDarkMode: colors.isDarkMode).opacity(0.1)) : AnyShapeStyle(appointment.foregroundColor(isDarkMode: colors.isDarkMode)), lineWidth: 1)
            )
            .padding(4)
    }
}

struct AppointmentRow: View {
    let appointment: Appointment
    let isSmallWidget: Bool
    let isTaskWidget: Bool
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetRenderingMode) var renderingMode

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private var timeText: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.locale = Locale(identifier: "en_US")
        
        let startTime = dateFormatter.string(from: appointment.startAt)
        let endTime = dateFormatter.string(from: appointment.endAt)
        
        // Check if both times are in the same period (AM/PM)
        let startPeriod = startTime.split(separator: " ")[1]
        let endPeriod = endTime.split(separator: " ")[1]
        
        if startPeriod == endPeriod {
            // Same period, show period only once at the end
            let startTimeOnly = startTime.split(separator: " ")[0]
            let endTimeOnly = endTime.split(separator: " ")[0]
            // Remove minutes if they are 00
            let formattedStart = startTimeOnly.hasSuffix(":00") ? String(startTimeOnly.split(separator: ":")[0]) : String(startTimeOnly)
            let formattedEnd = endTimeOnly.hasSuffix(":00") ? String(endTimeOnly.split(separator: ":")[0]) : String(endTimeOnly)
            return "\(formattedStart) – \(formattedEnd) \(startPeriod)"
        } else {
            // Different periods, show period for each time
            let formattedStart = startTime.hasSuffix(":00 AM") || startTime.hasSuffix(":00 PM") ?
                String(startTime.split(separator: ":")[0]) + String(startTime[startTime.firstIndex(of: " ")!...]) :
                startTime
            let formattedEnd = endTime.hasSuffix(":00 AM") || endTime.hasSuffix(":00 PM") ?
                String(endTime.split(separator: ":")[0]) + String(endTime[endTime.firstIndex(of: " ")!...]) :
                endTime
            return "\(formattedStart) – \(formattedEnd)"
        }
    }

    private var taskStartTimeText: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.locale = Locale(identifier: "en_US")
        let startTime = dateFormatter.string(from: appointment.startAt)
        let startPeriod = startTime.split(separator: " ")[1]
        let startTimeOnly = startTime.split(separator: " ")[0]
        let formattedStart = startTimeOnly.hasSuffix(":00") ? String(startTimeOnly.split(separator: ":")[0]) : String(startTimeOnly)
        return "\(formattedStart) \(startPeriod)"
    }
    
    var body: some View {
        let colors = VisirColorScheme.getColor(for: colorScheme)
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .background(appointment.backgroundColor(isDarkMode: colors.isDarkMode))
                .foregroundColor(.clear)
                .cornerRadius(6)
                .overlay(
                    VStack(alignment: .leading, spacing: 2) {
                        if !appointment.isAllDay {
                            Text(timeText)
                                .font(.custom("SUITE-Medium", size: 11))
                                .foregroundColor(appointment.textColor(isDarkMode: colors.isDarkMode))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(1)
                        }
                        Text(appointment.title)
                            .font(.caption)
                            .foregroundColor(appointment.textColor(isDarkMode: colors.isDarkMode))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(1)
                            .padding(.leading, appointment.isEvent ? 0 : 16)
                    }
                    .padding(.leading, 6)
                    .padding(.trailing, 2)
                    .padding(.vertical, 4)
                )
                .frame(height: (appointment.isAllDay) ? 22 : 38, alignment: .leading)
                .overlay(
                    isSmallWidget ? nil :
                    Button(
                        intent: OpenAppIntent(
                            url: URL(string: "com.wavetogether.fillin://moveToDate?date=\(dateFormatter.string(from: appointment.startAt))"),
                            appGroup: "group.com.wavetogether.fillin"
                        )
                    ) {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .buttonStyle(.plain)
                )

            if !appointment.isEvent {
                if isSmallWidget {
                    AppointmentCheckButton(appointment: appointment)
                        .padding(.leading, 2)
                        .padding(.bottom, 1)
                } else {
                    Button(
                        intent: BackgroundIntent(
                            url: URL(string: "com.wavetogether.fillin://toggletaskstatus?id=\(appointment.id)&recurringTaskId=\(appointment.recurringTaskId ?? "")&startAtMs=\(appointment.startAtMs)&endAtMs=\(appointment.endAtMs)"),
                            appGroup: "group.com.wavetogether.fillin"
                        )
                    ) {
                        AppointmentCheckButton(appointment: appointment)
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 2)
                    .padding(.bottom, 1)
                }
            }
        }
        .padding(2)
    }
}

struct InboxRow: View {
    let inbox: Inbox
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetRenderingMode) var renderingMode
    
    var body: some View {        
        let colors = VisirColorScheme.getColor(for: colorScheme)

        Button(
            intent: OpenAppIntent(
                url: URL(string: "com.wavetogether.fillin://openinboxitem?id=\(inbox.id)"),
                appGroup: "group.com.wavetogether.fillin"
            )
        ) {
            VStack(spacing: 6) {
                HStack(spacing: 0) {
                    Image(inbox.providerIcon.components(separatedBy: "/").last?.replacingOccurrences(of: ".png", with: "") ?? "")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .padding(.trailing, 4)
                    Text(inbox.providerName)
                        .font(.caption)
                        .foregroundColor(colors.shadow)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .allowsTightening(true)
                        .frame(maxWidth: .infinity, maxHeight: 14, alignment: .topLeading)
                    Text(inbox.timeString)
                        .font(.system(size: 11))
                        .foregroundColor(colors.surfaceTint)
                        .frame(maxHeight: 14)
                        .padding(.leading, 6)
                }
                .frame(maxWidth: .infinity)
                HStack(spacing: 0) {
                    if let userName = inbox.messageUserName, !userName.isEmpty {
                        Text(userName)
                            .font(.caption.bold())
                            .foregroundColor(colors.shadow)
                            .padding(.trailing, 6)
                    }
                    Text(inbox.title)
                        .font(.caption)
                        .foregroundColor(colors.shadow)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .allowsTightening(true)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(renderingMode.description == "accented" ? AnyShapeStyle(colors.outline.opacity(0.1)) : AnyShapeStyle(colors.outline))
            .cornerRadius(6)
            .padding(2)
        }
        .buttonStyle(.plain)
    }
}