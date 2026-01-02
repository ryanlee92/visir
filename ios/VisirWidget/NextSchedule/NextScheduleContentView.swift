import SwiftUI
import WidgetKit

struct NextScheduleContentView: View {
    let data: NextScheduleData
    let availableHeight: CGFloat
    let colors: (isDarkMode: Bool, background: Color, onBackground: Color, outline: Color, shadow: Color, onInverseSurface: Color, surfaceTint: Color, primary: Color, secondary: Color, error: Color, tertiary: Color, surface: Color)
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d, yyyy h:mm a"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    private var startDate: Date {
        Date(timeIntervalSince1970: TimeInterval(data.startTimeMs) / 1000.0)
    }
    
    private var endDate: Date {
        Date(timeIntervalSince1970: TimeInterval(data.endTimeMs) / 1000.0)
    }
    
    private var color: Color {
        Color(UIColor(
            red: CGFloat((data.colorInt >> 16) & 0xFF) / 255.0,
            green: CGFloat((data.colorInt >> 8) & 0xFF) / 255.0,
            blue: CGFloat(data.colorInt & 0xFF) / 255.0,
            alpha: CGFloat((data.colorInt >> 24) & 0xFF) / 255.0
        ))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Event details
            VStack(alignment: .leading, spacing: 8) {
                // Title with color bar (event) or border square (task)
                HStack(spacing: 6) {
                    if data.isEvent {
                        // Event: filled rounded rectangle bar
                        Rectangle()
                            .fill(color)
                            .frame(width: 4, height: 20)
                            .cornerRadius(2)
                    } else {
                        // Task: rounded square with border only
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(color, lineWidth: 2)
                            .frame(width: 16, height: 16)
                    }
                    Text(data.title)
                        .font(.custom("SUITE-Medium", size: 16))
                        .foregroundColor(colors.onBackground)
                        .lineLimit(2)
                }
                
                // Date, duration, type
                Text("\(dateFormatter.string(from: startDate)) • \(data.duration) min • \(data.projectName ?? data.calendarName ?? "")")
                    .font(.custom("SUITE-Medium", size: 12))
                    .foregroundColor(colors.onInverseSurface)
                    .lineLimit(2)
                
                // Previous Context (if available)
                if let previousContext = data.previousContext {
                    PreviousContextView(context: previousContext, colors: colors)
                }
            }
            .padding(.top, 14)
            .padding(.bottom, 4)
            .padding(.horizontal, 14)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct PreviousContextView: View {
    let context: PreviousContext
    let colors: (isDarkMode: Bool, background: Color, onBackground: Color, outline: Color, shadow: Color, onInverseSurface: Color, surfaceTint: Color, primary: Color, secondary: Color, error: Color, tertiary: Color, surface: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 16))
                    .foregroundColor(colors.onBackground)
                Text("Previous Context")
                    .font(.custom("SUITE-Medium", size: 12))
                    .foregroundColor(colors.onBackground)
            }
            
            Text(context.summary)
                .font(.custom("SUITE-Medium", size: 11))
                .foregroundColor(colors.onBackground)
                .lineLimit(5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(8)
        .background(colors.surface.opacity(0.5))
        .cornerRadius(8)
    }
}

struct NextScheduleData: Codable {
    let title: String
    let startTimeMs: Int64
    let endTimeMs: Int64
    let duration: Int
    let isEvent: Bool
    let eventId: String?
    let taskId: String?
    let colorInt: Int
    let location: String?
    let conferenceLink: String?
    let projectName: String?
    let calendarName: String?
    let previousContext: PreviousContext?
}

struct PreviousContext: Codable {
    let summary: String
    
    // 기존 필드들도 옵셔널로 처리하여 하위 호환성 유지
    let mostRecentDate: String?
    let mostRecentStartTime: String?
    let mostRecentEndTime: String?
    let recurrenceDescription: String?
    let startDate: String?
    let lastDate: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // summary 필드가 있으면 사용, 없으면 nil
        summary = try container.decodeIfPresent(String.self, forKey: .summary) ?? ""
        
        // 기존 필드들도 디코딩 시도 (하위 호환성)
        mostRecentDate = try container.decodeIfPresent(String.self, forKey: .mostRecentDate)
        mostRecentStartTime = try container.decodeIfPresent(String.self, forKey: .mostRecentStartTime)
        mostRecentEndTime = try container.decodeIfPresent(String.self, forKey: .mostRecentEndTime)
        recurrenceDescription = try container.decodeIfPresent(String.self, forKey: .recurrenceDescription)
        startDate = try container.decodeIfPresent(String.self, forKey: .startDate)
        lastDate = try container.decodeIfPresent(String.self, forKey: .lastDate)
    }
    
    enum CodingKeys: String, CodingKey {
        case summary
        case mostRecentDate
        case mostRecentStartTime
        case mostRecentEndTime
        case recurrenceDescription
        case startDate
        case lastDate
    }
}

