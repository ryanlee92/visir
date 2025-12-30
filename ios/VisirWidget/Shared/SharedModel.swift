import SwiftUI
import WidgetKit
import UIKit

struct WidgetDataEntry: TimelineEntry {
    let date: Date
    var dateGroupedAppointments: [String: DateGroupedAppointments]
    var inboxes: [Inbox]
    var inboxUpdatedAt: Date?
}

struct DateGroupedAppointments: Codable {
    var appointments: [Appointment]
    var eventAlldayCount: Int
    var taskAlldayCount: Int
    
    var activeAppointments: [Appointment] {
        let now = Date()
        return appointments.filter { appointment in
            !appointment.isDone && appointment.endAtMs > Int64(now.timeIntervalSince1970 * 1000)
        }
    }
}

extension Color {
    var hsv: (hue: CGFloat, saturation: CGFloat, value: CGFloat) {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var v: CGFloat = 0
        UIColor(self).getHue(&h, saturation: &s, brightness: &v, alpha: nil)
        return (h, s, v)
    }
    
    func withValue(_ value: CGFloat) -> Color {
        let hsv = self.hsv
        return Color(UIColor(hue: hsv.hue, saturation: hsv.saturation, brightness: value, alpha: 1.0))
    }
    
    func withSaturation(_ saturation: CGFloat) -> Color {
        let hsv = self.hsv
        return Color(UIColor(hue: hsv.hue, saturation: saturation, brightness: hsv.value, alpha: 1.0))
    }
    
    func withAlpha(_ alpha: CGFloat) -> Color {
        Color(UIColor(self).withAlphaComponent(alpha))
    }
}

struct Appointment: Codable {
    let id: String
    let title: String
    let colorInt: Int
    let startAtMs: Int64
    let endAtMs: Int64
    let isAllDay: Bool
    var isDone: Bool
    let recurringTaskId: String?
    let isEvent: Bool
    let projectId: String?
    let calendarUniqueId: String?
    
    private func color(isDarkMode: Bool) -> Color {
        Color(UIColor(
            red: CGFloat((colorInt >> 16) & 0xFF) / 255.0,
            green: CGFloat((colorInt >> 8) & 0xFF) / 255.0,
            blue: CGFloat(colorInt & 0xFF) / 255.0,
            alpha: CGFloat((colorInt >> 24) & 0xFF) / 255.0
        ))
    }
    
    private func _baseBackgroundColor(isDarkMode: Bool) -> Color {
        var hsv = color(isDarkMode: isDarkMode).hsv
        
        if !isDarkMode {
            if hsv.value > 0.7 && hsv.saturation >= 0.2 && hsv.saturation < 0.5 {
                hsv.value = 0.7
            } else if hsv.value > 0.5 && hsv.saturation < 0.2 {
                hsv.value = 0.5
            } else if hsv.value > 0.9 && hsv.saturation >= 0.5 {
                hsv.value = 0.9
            }
        }
        
        return Color(UIColor(hue: hsv.hue, saturation: hsv.saturation, brightness: hsv.value, alpha: 1.0))
    }
    
    func backgroundColor(isDarkMode: Bool) -> Color {
        let hsv = _baseBackgroundColor(isDarkMode: isDarkMode).hsv
        let alpha = hsv.value <= 0.6 && isDarkMode ? 0.3 : 0.15
        return _baseBackgroundColor(isDarkMode: isDarkMode).withAlpha(alpha)
    }
    
    func foregroundColor(isDarkMode: Bool) -> Color {
        var hsv = _baseBackgroundColor(isDarkMode: isDarkMode).hsv
        
        if isDarkMode && hsv.value <= 0.6 {
            hsv.value = 0.9
        }
        
        return Color(UIColor(hue: hsv.hue, saturation: hsv.saturation, brightness: hsv.value, alpha: 1.0))
    }
    
    func textColor(isDarkMode: Bool) -> Color {
        var hsv = _baseBackgroundColor(isDarkMode: isDarkMode).hsv
        
        if isDarkMode {
            if hsv.value <= 0.6 {
                hsv.value = 0.9
            }
            hsv.saturation = 0.1
            hsv.value = 1.0
        } else {
            if hsv.hue > 0.4 && hsv.hue < 0.95 && hsv.value > 0.7 && hsv.saturation >= 0.5 {
                hsv.value = 0.7
            }
            hsv.saturation = 0.95
            hsv.value = 0.3
        }
        
        return Color(UIColor(hue: hsv.hue, saturation: hsv.saturation, brightness: hsv.value, alpha: 1.0))
    }
    
    var startAt: Date {
        Date(timeIntervalSince1970: TimeInterval(startAtMs) / 1000.0)
    }
    
    var endAt: Date {
        Date(timeIntervalSince1970: TimeInterval(endAtMs) / 1000.0)
    }
}

struct Inbox: Codable {
    let id: String
    let title: String
    let providerIcon: String
    let providerName: String
    let timeString: String
    let messageUserName: String?
}


struct Provider: TimelineProvider {
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    func placeholder(in context: Context) -> WidgetDataEntry {
        return WidgetDataEntry(
            date: Date(),
            dateGroupedAppointments: [:],
            inboxes: [],
            inboxUpdatedAt: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetDataEntry) -> Void) {
        // Snapshot은 빠르게 반환해야 하므로, context.isPreview일 때는 placeholder를 사용
        if context.isPreview {
            completion(placeholder(in: context))
        } else {
            // 실제 위젯에서는 데이터를 로드하되, 빠르게 반환
            completion(loadEntry())
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetDataEntry>) -> Void) {
        // 타임라인을 즉시 생성하여 "waiting..." 상태를 방지
        let entry = loadEntry()
        let defaults = UserDefaults(suiteName: "group.com.wavetogether.fillin")
        
        // themeMode 변경을 감지하기 위한 옵저버 설정
        let center = NotificationCenter.default
        center.addObserver(forName: UserDefaults.didChangeNotification, object: defaults, queue: .main) { _ in
            WidgetCenter.shared.reloadAllTimelines()
        }
        
        // 자정 기준으로 위젯 업데이트
        let currentDate = Date()
        let calendar = Calendar.current
        let nextMidnight = calendar.nextDate(after: currentDate, matching: DateComponents(hour:0, minute:0, second:0), matchingPolicy: .nextTime) ?? calendar.startOfDay(for: currentDate).addingTimeInterval(86400)
        
        // 즉시 업데이트를 위해 현재 시간에도 entry를 포함
        // 5분 후에도 다시 업데이트하여 데이터가 변경되면 반영되도록 함
        let nextUpdate = min(nextMidnight, currentDate.addingTimeInterval(300)) // 5분 또는 자정 중 더 빠른 시간
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadEntry() -> WidgetDataEntry {
        let defaults = UserDefaults(suiteName: "group.com.wavetogether.fillin")
        
        var dateGroupedAppointments: [String: DateGroupedAppointments] = [:]
        var inboxes: [Inbox] = []
        var inboxUpdatedAt: Date? = nil
        
        // Load projectHide and calendarHide lists from JSON strings
        var projectHide: [String] = []
        var calendarHide: [String] = []
        
        if let projectHideString = defaults?.string(forKey: "projectHide"),
           let projectHideData = projectHideString.data(using: .utf8) {
            do {
                projectHide = try JSONDecoder().decode([String].self, from: projectHideData)
            } catch {
                // Failed to decode projectHide
            }
        }
        
        if let calendarHideString = defaults?.string(forKey: "calendarHide"),
           let calendarHideData = calendarHideString.data(using: .utf8) {
            do {
                calendarHide = try JSONDecoder().decode([String].self, from: calendarHideData)
            } catch {
                // Failed to decode calendarHide
            }
        }
        
        // Check dateGroupedAppointments
        if let jsonString = defaults?.string(forKey: "dateGroupedAppointments"),
           let jsonData = jsonString.data(using: .utf8) {
            do {
                var appointments = try JSONDecoder().decode([String: DateGroupedAppointments].self, from: jsonData)
                
                // Filter out appointments where isDone is true, projectHide contains projectId, or calendarHide contains calendarUniqueId
                appointments = appointments.mapValues { appointments in
                    var filteredAppointments = appointments
                    filteredAppointments.appointments = appointments.appointments.filter { appointment in
                        // Filter out done appointments
                        if appointment.isDone {
                            return false
                        }
                        
                        // Filter out tasks in projectHide
                        if !appointment.isEvent, let projectId = appointment.projectId, projectHide.contains(projectId) {
                            return false
                        }
                        
                        // Filter out events in calendarHide
                        if appointment.isEvent, let calendarUniqueId = appointment.calendarUniqueId, calendarHide.contains(calendarUniqueId) {
                            return false
                        }
                        
                        return true
                    }
                    return filteredAppointments
                }
                
                dateGroupedAppointments = appointments
            } catch {
                // Failed to decode dateGroupedAppointments
            }
        }
        
        // Check inboxes
        if let jsonString = defaults?.string(forKey: "inboxes"),
           let jsonData = jsonString.data(using: .utf8) {
            do {
                inboxes = try JSONDecoder().decode([Inbox].self, from: jsonData)
            } catch {
                // Failed to decode inboxes
            }
        }
        
        // Check inboxUpdatedAt
        if let dateString = defaults?.string(forKey: "inboxUpdatedAt") {
            let formatter = DateFormatter()
            
            // Try with microseconds (6 digits) and no timezone
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
            inboxUpdatedAt = formatter.date(from: dateString)
            
            if inboxUpdatedAt == nil {
                // Try with milliseconds (3 digits) and no timezone
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                inboxUpdatedAt = formatter.date(from: dateString)
            }
            
            if inboxUpdatedAt == nil {
                // Try with timezone
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                inboxUpdatedAt = formatter.date(from: dateString)
            }
            
            if inboxUpdatedAt == nil {
                // Try without milliseconds and with timezone
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                inboxUpdatedAt = formatter.date(from: dateString)
            }
        }

        
        return WidgetDataEntry(
            date: Date(),
            dateGroupedAppointments: dateGroupedAppointments,
            inboxes: inboxes,
            inboxUpdatedAt: inboxUpdatedAt
        )
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
