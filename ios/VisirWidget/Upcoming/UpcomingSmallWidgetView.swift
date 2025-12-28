import SwiftUI
import WidgetKit

struct UpcomingSmallWidgetView: View {
    var entry: Provider.Entry
    @State private var taskRowHeight: CGFloat = 0
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetRenderingMode) var renderingMode
    
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

    private func selectAppointment(from appointments: [Appointment]) -> Appointment? {
        let now = Date()
        let nonAllDayAppointments = appointments.filter { !$0.isAllDay }
        
        // 현재 진행 중인 일정들
        let ongoingAppointments = nonAllDayAppointments.filter { appointment in
            now >= appointment.startAt && now <= appointment.endAt
        }
        
        // 진행 중인 일정이 있는 경우
        if !ongoingAppointments.isEmpty {
            // startAt이 가장 늦은 것들 중에서
            let latestStartAppointments = ongoingAppointments.filter { appointment in
                appointment.startAt == ongoingAppointments.map { $0.startAt }.max()
            }
            
            // endAt이 가장 빠른 것 선택
            if let earliestEndAppointment = latestStartAppointments.min(by: { $0.endAt < $1.endAt }) {
                // startAt과 endAt이 같은 경우 isEvent가 false인 것 우선
                let sameTimeAppointments = latestStartAppointments.filter { $0.startAt == earliestEndAppointment.startAt && $0.endAt == earliestEndAppointment.endAt }
                return sameTimeAppointments.first { !$0.isEvent } ?? sameTimeAppointments.first
            }
        }
        
        // 진행 중인 일정이 없는 경우, 남은 일정들 중에서 선택
        let remainingAppointments = nonAllDayAppointments.filter { $0.endAt > now }
        if !remainingAppointments.isEmpty {
            // startAt이 가장 빠른 것들 중에서
            let earliestStartAppointments = remainingAppointments.filter { appointment in
                appointment.startAt == remainingAppointments.map { $0.startAt }.min()
            }
            
            // endAt이 가장 빠른 것 선택
            if let earliestEndAppointment = earliestStartAppointments.min(by: { $0.endAt < $1.endAt }) {
                // startAt과 endAt이 같은 경우 isEvent가 false인 것 우선
                let sameTimeAppointments = earliestStartAppointments.filter { $0.startAt == earliestEndAppointment.startAt && $0.endAt == earliestEndAppointment.endAt }
                return sameTimeAppointments.first { !$0.isEvent } ?? sameTimeAppointments.first
            }
        }
        
        return nil
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
                        .frame(maxWidth: .infinity, maxHeight: 12, alignment: .leading)
                        .padding(1)
                    Text(entry.date.formatted(.dateTime.day()))
                        .font(.custom("SUITE-Bold", size: 30))
                        .foregroundColor(colors.onBackground)
                        .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
                        .padding(2)
                    Spacer()
                    if let todayData = todayData {
                        if (todayData.eventAlldayCount + todayData.taskAlldayCount) == 1 {
                            if let firstAllDayAppointment = todayData.activeAppointments.first(where: { $0.isAllDay }) {
                                AppointmentRow(appointment: firstAllDayAppointment, isSmallWidget: true, isTaskWidget: false)
                            }
                        } else {
                            AllDayRow(appointments: todayData.activeAppointments.filter { $0.isAllDay }, emptyText: nil)
                        }
                        if let selectedAppointment = selectAppointment(from: todayData.activeAppointments) {
                            AppointmentRow(appointment: selectedAppointment, isSmallWidget: true, isTaskWidget: false)
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