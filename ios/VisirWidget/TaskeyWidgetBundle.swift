import WidgetKit
import SwiftUI

@main
struct VisirWidgetBundle: WidgetBundle {
    var body: some Widget {
        TodayWidget()
        UpcomingWidget()
        TaskWidget()
        CalendarMonthWidget()
        NextScheduleWidget()
        // VisirWidgetLiveActivity()
    }
}
