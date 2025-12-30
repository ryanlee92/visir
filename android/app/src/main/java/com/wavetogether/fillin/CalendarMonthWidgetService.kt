package com.wavetogether.fillin

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*

class CalendarMonthWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        val colors = VisirColorScheme(
            primary = intent.getIntExtra("primary", 0),
            onBackground = intent.getIntExtra("onBackground", 0),
            background = intent.getIntExtra("background", 0),
            onInverseSurface = intent.getIntExtra("onInverseSurface", 0),
            shadow = intent.getIntExtra("shadow", 0),
            outline = intent.getIntExtra("outline", 0),
            surfaceTint = intent.getIntExtra("surfaceTint", 0),
            secondary = intent.getIntExtra("secondary", 0),
            error = intent.getIntExtra("error", 0),
            tertiary = intent.getIntExtra("tertiary", 0),
            surface = intent.getIntExtra("surface", 0)
        )
        val cellHeightPx = intent.getIntExtra("cellHeightPx", 0)
        return CalendarMonthWidgetServiceFactory(applicationContext, colors, cellHeightPx)
    }
}

class CalendarMonthWidgetServiceFactory(
    private val context: Context,
    private val colors: VisirColorScheme,
    private val cellHeightPx: Int
) : RemoteViewsService.RemoteViewsFactory {
    private var calendarDays: List<CalendarDay> = emptyList()
    private var appointmentsMap: Map<String, List<AppointmentData>> = emptyMap()

    override fun onCreate() {
    }

    override fun onDestroy() {
    }

    override fun onDataSetChanged() {
        try {
            val widgetData = HomeWidgetPlugin.getData(context)
            val calendar = Calendar.getInstance()
            calendar.set(Calendar.DAY_OF_MONTH, 1)
            
            // Load appointments data
            val appointmentsJson = widgetData.getString("dateGroupedAppointments", "{}") ?: "{}"
            appointmentsMap = parseAppointments(appointmentsJson)
            
            val firstDayOfMonth = calendar.get(Calendar.DAY_OF_WEEK)
            val daysInMonth = calendar.getActualMaximum(Calendar.DAY_OF_MONTH)
            
            val days = mutableListOf<CalendarDay>()
            
            // Calculate start date (7 days before first day of month for 6-week grid)
            val startCalendar = calendar.clone() as Calendar
            startCalendar.add(Calendar.DAY_OF_MONTH, -(firstDayOfMonth - 1))
            
            // Generate 42 days (6 weeks)
            val today = Calendar.getInstance()
            for (i in 0 until 42) {
                val currentDate = startCalendar.clone() as Calendar
                currentDate.add(Calendar.DAY_OF_MONTH, i)
                
                val isCurrentMonth = currentDate.get(Calendar.MONTH) == calendar.get(Calendar.MONTH) &&
                        currentDate.get(Calendar.YEAR) == calendar.get(Calendar.YEAR)
                val isToday = currentDate.get(Calendar.YEAR) == today.get(Calendar.YEAR) &&
                        currentDate.get(Calendar.MONTH) == today.get(Calendar.MONTH) &&
                        currentDate.get(Calendar.DAY_OF_MONTH) == today.get(Calendar.DAY_OF_MONTH)
                
                // Always show day number, even for previous/next month
                val dayNumber = currentDate.get(Calendar.DAY_OF_MONTH)
                
                // Get appointments for this date
                // Format: ISO8601 format (e.g., "2024-01-15T00:00:00.000Z" or "2024-01-15T00:00:00.000")
                val dateFormat = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
                val dateString = dateFormat.format(currentDate.time)
                
                // Try to find appointments with this date prefix (ISO8601 format)
                // The key format is ISO8601, so we match by date prefix
                val appointments = appointmentsMap.entries
                    .filter { 
                        val keyDate = it.key.substring(0, minOf(10, it.key.length))
                        keyDate == dateString
                    }
                    .flatMap { it.value }
                    .toList()
                
                days.add(CalendarDay(
                    day = dayNumber,
                    isCurrentMonth = isCurrentMonth,
                    isToday = isToday,
                    date = currentDate.time,
                    appointments = appointments
                ))
            }
            
            calendarDays = days
        } catch (e: Exception) {
            e.printStackTrace()
            calendarDays = emptyList()
            appointmentsMap = emptyMap()
        }
    }
    
    private fun parseAppointments(jsonString: String): Map<String, List<AppointmentData>> {
        val result = mutableMapOf<String, List<AppointmentData>>()
        try {
            if (jsonString == "{}" || jsonString.isEmpty()) return result
            
            val jsonObject = JSONObject(jsonString)
            val keys = jsonObject.keys()
            
            while (keys.hasNext()) {
                val dateKey = keys.next()
                val dateData = jsonObject.getJSONObject(dateKey)
                val appointmentsArray = dateData.getJSONArray("appointments")
                
                val appointments = mutableListOf<AppointmentData>()
                for (i in 0 until appointmentsArray.length()) {
                    val appointment = appointmentsArray.getJSONObject(i)
                    appointments.add(AppointmentData(
                        title = appointment.optString("title", ""),
                        colorInt = appointment.optInt("colorInt", Color.GRAY),
                        isAllDay = appointment.optBoolean("isAllDay", false)
                    ))
                }
                
                result[dateKey] = appointments
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return result
    }

    override fun getCount(): Int {
        return calendarDays.size
    }

    override fun getViewAt(position: Int): RemoteViews {
        val day = calendarDays.getOrNull(position) ?: CalendarDay(day = 0, isCurrentMonth = false)
        
        val remoteViews = RemoteViews(context.packageName, R.layout.calendar_day_item)
        
        // Set explicit height for the cell to ensure even distribution
        // Note: RemoteViews doesn't support setting layout params directly
        // We'll try to use setInt to set minimum height
        if (cellHeightPx > 0) {
            remoteViews.setInt(R.id.day_item_root, "setMinimumHeight", cellHeightPx)
        }
        
        // Set day number - always show, even for previous/next month
        remoteViews.setTextViewText(R.id.day_number, day.day.toString())
        if (day.isToday) {
            remoteViews.setTextColor(R.id.day_number, colors.secondary)
            // Note: Setting background color with opacity in RemoteViews is limited
            // We'll use a drawable resource or set a solid color
            // For now, we'll skip the background color as RemoteViews doesn't support alpha well
        } else if (day.isCurrentMonth) {
            // Current month: full color
            remoteViews.setTextColor(R.id.day_number, colors.onBackground)
        } else {
            // Previous/next month: use surfaceTint color (gray) instead of opacity
            remoteViews.setTextColor(R.id.day_number, colors.surfaceTint)
        }
        
        // Clear and add events
        remoteViews.removeAllViews(R.id.events_container)
        
        // Show events for all days (including previous/next month)
        if (day.appointments.isNotEmpty()) {
            // Calculate max visible events based on cell height
            // Day number takes ~13dp (11sp font + padding)
            // Each event box is ~8dp (7sp font + 1.5dp padding * 2)
            // Use very conservative calculation to prevent overflow
            val dayNumberHeightDp = 15f // More conservative estimate
            val eventBoxHeightDp = 10f // More conservative: 7sp text + 1.5dp padding * 2 + spacing
            val density = context.resources.displayMetrics.density
            val cellHeightDp = cellHeightPx / density
            // Subtract day number height and larger safety margin (5dp total)
            val availableHeightDp = cellHeightDp - dayNumberHeightDp - 5 // 5dp total safety margin
            val maxVisible = maxOf(0, minOf(day.appointments.size, (availableHeightDp / eventBoxHeightDp).toInt()))
            
            // Ensure we don't exceed available space even with "..." indicator
            // Be very conservative: always reserve space for "..." if there are more events
            val maxEventsWithIndicator = if (day.appointments.size > maxVisible && maxVisible > 0) {
                maxOf(0, maxVisible - 1) // Reserve space for "..." indicator
            } else {
                maxVisible
            }
            
            for (i in 0 until maxEventsWithIndicator) {
                val appointment = day.appointments[i]
                val eventView = RemoteViews(context.packageName, R.layout.calendar_event_item)
                
                // Set event text (just the title, no dot)
                eventView.setTextViewText(R.id.event_text, appointment.title)
                
                // Set event text color - use gray for previous/next month
                if (day.isCurrentMonth) {
                    eventView.setTextColor(R.id.event_text, appointment.colorInt)
                } else {
                    // Previous/next month: use gray color instead of opacity
                    eventView.setTextColor(R.id.event_text, colors.surfaceTint)
                }
                
                // Set background color with opacity (only for current month)
                if (day.isCurrentMonth) {
                    val bgColor = appointment.colorInt
                    val r = Color.red(bgColor)
                    val g = Color.green(bgColor)
                    val b = Color.blue(bgColor)
                    val bgAlpha = 0x26 // ~15% opacity
                    val bgColorWithAlpha = Color.argb(bgAlpha, r, g, b)
                    eventView.setInt(R.id.event_text, "setBackgroundColor", bgColorWithAlpha)
                } else {
                    // Previous/next month: no background or very light gray background
                    eventView.setInt(R.id.event_text, "setBackgroundColor", Color.TRANSPARENT)
                }
                
                remoteViews.addView(R.id.events_container, eventView)
            }
            
            // Show "..." if there are more events
            if (day.appointments.size > maxEventsWithIndicator) {
                val moreView = RemoteViews(context.packageName, R.layout.calendar_event_item)
                moreView.setTextViewText(R.id.event_text, "...")
                moreView.setTextColor(R.id.event_text, colors.surfaceTint)
                moreView.setInt(R.id.event_text, "setBackgroundColor", Color.TRANSPARENT)
                remoteViews.addView(R.id.events_container, moreView)
            }
        }
        
        // Set click intent
        if (day.date != null) {
            val fillInIntent = Intent()
            val dateFormat = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
            val dateString = dateFormat.format(day.date)
            fillInIntent.data = Uri.parse("com.wavetogether.fillin://moveToDate?date=$dateString")
            remoteViews.setOnClickFillInIntent(R.id.day_number, fillInIntent)
        }
        
        return remoteViews
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long = position.toLong()

    override fun hasStableIds(): Boolean = true
}

data class CalendarDay(
    val day: Int,
    val isCurrentMonth: Boolean = true,
    val isToday: Boolean = false,
    val date: Date? = null,
    val appointments: List<AppointmentData> = emptyList()
)

data class AppointmentData(
    val title: String,
    val colorInt: Int,
    val isAllDay: Boolean
)

