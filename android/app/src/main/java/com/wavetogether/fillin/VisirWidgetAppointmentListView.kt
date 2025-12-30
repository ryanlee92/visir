package com.wavetogether.fillin

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*
import android.app.PendingIntent
import android.os.Build
import android.content.BroadcastReceiver
import android.content.IntentFilter
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.res.Configuration
import com.wavetogether.fillin.VisirColorScheme

class VisirWidgetAppointmentListView : RemoteViewsService() {
    private var isTaskWidget: Boolean = false

    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        isTaskWidget = intent.getBooleanExtra("isTaskWidget", false)
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
        return VisirWidgetAppointmentListViewFactory(applicationContext, colors, isTaskWidget)
    }
}

class VisirWidgetAppointmentListViewFactory(
    private val context: Context,
    private val colors: VisirColorScheme,
    private val isTaskWidget: Boolean
) : RemoteViewsService.RemoteViewsFactory {
    private var appointments: List<Appointment> = emptyList()
    private var dateGroupedAppointments: Map<String, Map<String, Any>> = emptyMap()

    private fun dpToPx(dp: Int): Int {
        return (dp * context.resources.displayMetrics.density).toInt()
    }

    override fun onCreate() {
    }

    override fun onDestroy() {
        // No need for theme receiver cleanup here anymore
    }

    override fun onDataSetChanged() {
        try {
            val widgetData = HomeWidgetPlugin.getData(context)
            val appointmentsJson = widgetData.getString("dateGroupedAppointments", "{}") ?: "{}"
            
            if (appointmentsJson == "{}") {
                return
            }
            
            val jsonObject = JSONObject(appointmentsJson)
            val allAppointments = mutableListOf<Appointment>()
            val grouped = mutableMapOf<String, Map<String, Any>>()

            // Get today's date and 6 days later (total 7 days)
            val calendar = Calendar.getInstance()
            val today = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(calendar.time)
            
            calendar.add(Calendar.DAY_OF_MONTH, 6)
            val sixDaysLater = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(calendar.time)

            // Parse grouped appointments
            val keys = jsonObject.keys()
            while (keys.hasNext()) {
                val dateKey = keys.next()
                
                try {
                    // Check if the date is within the range (today to 6 days later)
                    val appointmentDate = dateKey.split("T")[0]
                    if (appointmentDate < today || appointmentDate > sixDaysLater) {
                        continue // Skip appointments outside the range
                    }

                    val dateData = jsonObject.getJSONObject(dateKey)
                    val appointmentsArray = dateData.getJSONArray("appointments")
                    
                    val dateAppointments = mutableListOf<Appointment>()
                    var eventAlldayCount = 0
                    var taskAlldayCount = 0
                    
                    for (i in 0 until appointmentsArray.length()) {
                        try {
                            val appointmentJson = appointmentsArray.getJSONObject(i)
                            val appointment = parseAppointment(appointmentJson)
                            // Skip if appointment is done or has ended
                            if (!appointment.isDone && appointment.endAtMs > System.currentTimeMillis()) {
                                dateAppointments.add(appointment)
                                allAppointments.add(appointment)
                                
                                // Update all-day counts
                                if (appointment.isAllDay) {
                                    if (appointment.isEvent) {
                                        eventAlldayCount++
                                    } else {
                                        taskAlldayCount++
                                    }
                                }
                            }
                        } catch (e: Exception) {
                            e.printStackTrace()
                        }
                    }
                    
                    grouped[dateKey] = mapOf(
                        "appointments" to dateAppointments,
                        "eventAlldayCount" to eventAlldayCount,
                        "taskAlldayCount" to taskAlldayCount
                    )
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }

            appointments = allAppointments
            dateGroupedAppointments = grouped
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
    
    override fun getCount(): Int {
        var count = 0
        dateGroupedAppointments.forEach { (_, dateData) ->
            @Suppress("UNCHECKED_CAST")
            val appointments = dateData["appointments"] as? List<Appointment> ?: emptyList()
            // Add 1 for each date to account for date header
            count += appointments.size + 1
        }
        return count
    }

    override fun getViewAt(position: Int): RemoteViews {
        try {
            var currentPosition = 0
            var currentDate: String? = null
            var currentAppointment: Appointment? = null
            var isFirstInDate = false
            var currentDateData: Map<String, Any>? = null
            var isDateHeader = false

            // Find the correct date and appointment for the given position
            for ((date, dateData) in dateGroupedAppointments) {
                // First position in each date group is for the date header
                if (currentPosition == position) {
                    currentDate = date
                    currentDateData = dateData
                    isDateHeader = true
                    break
                }
                currentPosition++

                @Suppress("UNCHECKED_CAST")
                val appointments = dateData["appointments"] as? List<Appointment> ?: emptyList()
                
                for (appointment in appointments) {
                    if (currentPosition == position) {
                        currentDate = date
                        currentAppointment = appointment
                        currentDateData = dateData
                        isFirstInDate = appointments.indexOf(appointment) == 0
                        break
                    }
                    currentPosition++
                }
                if (currentAppointment != null) break
            }

            try {
                val views = RemoteViews(context.packageName, R.layout.task_item)
                
                // Set date header visibility
                val today = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(Date())
                val currentDateFormatted = currentDate?.split("T")?.get(0) ?: ""
                val showDateHeader = isDateHeader && currentDateFormatted != today

                // Set date header visibility independently
                views.setViewVisibility(R.id.date_header, if (showDateHeader) android.view.View.VISIBLE else android.view.View.GONE)
                views.setViewVisibility(R.id.appointment_container, if (isDateHeader) android.view.View.GONE else android.view.View.VISIBLE)
                
                if (showDateHeader && currentDateData != null) {
                    try {
                        val dateFormat = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
                        val displayFormat = SimpleDateFormat("EEE, MMM d", Locale.ENGLISH)
                        val date = dateFormat.parse(currentDate)
                        val eventAlldayCount = currentDateData["eventAlldayCount"] as? Int ?: 0
                        val taskAlldayCount = currentDateData["taskAlldayCount"] as? Int ?: 0
                        @Suppress("UNCHECKED_CAST")
                        val appointments = currentDateData["appointments"] as? List<Appointment> ?: emptyList()
                        
                        // Set date in the first TextView
                        views.setTextViewText(R.id.date_header_date, displayFormat.format(date))
                        views.setInt(R.id.date_header_date, "setTextColor", colors.onInverseSurface)
                        
                        // Set count in the second TextView
                        val countText = StringBuilder()
                        if (isTaskWidget) {
                            val taskCount = appointments.count { !it.isEvent }
                            if(taskCount > 0) {
                                views.setViewVisibility(R.id.date_header_count_frame, android.view.View.GONE)
                            } else {
                                countText.append("No tasks")
                                views.setViewVisibility(R.id.date_header_count_frame, android.view.View.VISIBLE)
                            }
                        } else {
                            if (eventAlldayCount == 0 && taskAlldayCount == 0) {
                                countText.append("No all-day events")
                                views.setViewVisibility(R.id.date_header_count_frame, android.view.View.VISIBLE)
                            } else {
                                views.setViewVisibility(R.id.date_header_count_frame, android.view.View.GONE)
                            }
                        }
                        views.setTextViewText(R.id.date_header_count, countText.toString())
                        views.setInt(R.id.date_header_count, "setTextColor", colors.shadow)
                        views.setInt(R.id.date_header_count_background, "setColorFilter", colors.outline)
                        
                        
                        // Force update the view
                        // set fill intent
                        val fillInIntent = Intent()
                        fillInIntent.data = Uri.parse("com.wavetogether.fillin://moveToDate?date=${currentDate}")
                        views.setOnClickFillInIntent(R.id.date_header_count, fillInIntent)

                    } catch (e: Exception) {
                        views.setTextViewText(R.id.date_header_date, currentDate)
                        views.setTextViewText(R.id.date_header_count, "")
                    }
                } else {
                    views.setTextViewText(R.id.date_header_date, "")
                    views.setTextViewText(R.id.date_header_count, "")
                }

                if (!isDateHeader && currentAppointment != null) {
                    // Set appointment container visibility
                    if (isTaskWidget && currentAppointment.isEvent) {
                        views.setViewVisibility(R.id.appointment_container, android.view.View.GONE)
                    } else {
                        views.setViewVisibility(R.id.appointment_container, android.view.View.VISIBLE)
                        //   set fill intent
                        val fillInIntent = Intent()
                        fillInIntent.data = Uri.parse("com.wavetogether.fillin://moveToDate?date=${currentDate}")
                        views.setOnClickFillInIntent(R.id.appointment_container, fillInIntent)
                    }

                    // Set background color with proper alpha handling
                    val backgroundColor = currentAppointment.backgroundColor(context)
                    views.setInt(R.id.task_item_root_background, "setAlpha", Color.alpha(backgroundColor))
                    views.setInt(R.id.task_item_root_background, "setColorFilter", Color.rgb(
                        Color.red(backgroundColor),
                        Color.green(backgroundColor),
                        Color.blue(backgroundColor)
                    ))
                    views.setInt(R.id.task_checkbox, "setBackgroundColor", Color.TRANSPARENT)
                    views.setInt(R.id.appointment_time, "setTextColor", currentAppointment.textColor(context))
                    views.setInt(R.id.appointment_title, "setTextColor", currentAppointment.textColor(context))

                    // Set appointment title
                    if (isTaskWidget && !currentAppointment.isAllDay) {
                        val timeFormat = SimpleDateFormat("h:mm a", Locale.ENGLISH)
                        val startDate = Date(currentAppointment.startAtMs)
                        val startTime = timeFormat.format(startDate)
                        // Remove minutes if they are 00
                        val formattedStart = if (startTime.endsWith(":00 AM") || startTime.endsWith(":00 PM")) 
                            startTime.split(":")[0] + startTime.substring(startTime.indexOf(" ")) 
                        else startTime
                        views.setTextViewText(R.id.appointment_title, "$formattedStart ${currentAppointment.title}")
                    } else {
                        views.setTextViewText(R.id.appointment_title, currentAppointment.title)
                    }

                    // Set appointment time
                    if (currentAppointment.isAllDay || isTaskWidget) {
                        views.setViewVisibility(R.id.appointment_time, android.view.View.GONE)
                    } else {
                        views.setViewVisibility(R.id.appointment_time, android.view.View.VISIBLE)

                        val timeFormat = SimpleDateFormat("h:mm a", Locale.ENGLISH)
                        val startDate = Date(currentAppointment.startAtMs)
                        val endDate = Date(currentAppointment.endAtMs)
                        
                        val startTime = timeFormat.format(startDate)
                        val endTime = timeFormat.format(endDate)
                        
                        // Check if both times are in the same period (AM/PM)
                        val startPeriod = startTime.split(" ")[1]
                        val endPeriod = endTime.split(" ")[1]
                        
                        val timeText = if (startPeriod == endPeriod) {
                            // Same period, show period only once at the end
                            val startTimeOnly = startTime.split(" ")[0]
                            val endTimeOnly = endTime.split(" ")[0]
                            // Remove minutes if they are 00
                            val formattedStart = if (startTimeOnly.endsWith(":00")) startTimeOnly.split(":")[0] else startTimeOnly
                            val formattedEnd = if (endTimeOnly.endsWith(":00")) endTimeOnly.split(":")[0] else endTimeOnly
                            "$formattedStart – $formattedEnd $startPeriod"
                        } else {
                            // Different periods, show period for each time
                            val formattedStart = if (startTime.endsWith(":00 AM") || startTime.endsWith(":00 PM")) 
                                startTime.split(":")[0] + startTime.substring(startTime.indexOf(" ")) 
                            else startTime
                            val formattedEnd = if (endTime.endsWith(":00 AM") || endTime.endsWith(":00 PM")) 
                                endTime.split(":")[0] + endTime.substring(endTime.indexOf(" ")) 
                            else endTime
                            "$formattedStart – $formattedEnd"
                        }
                        
                        views.setTextViewText(R.id.appointment_time, timeText)
                    }

                    // Set checkbox visibility and color
                    if (currentAppointment.isEvent) {
                        views.setViewVisibility(R.id.task_checkbox, android.view.View.GONE)
                        views.setViewVisibility(R.id.task_checkbox_inner, android.view.View.GONE)
                        views.setViewPadding(R.id.appointment_title, 0, 0, 0, 0)
                    } else {
                        views.setViewVisibility(R.id.task_checkbox, android.view.View.VISIBLE)
                        views.setViewVisibility(R.id.task_checkbox_inner, android.view.View.VISIBLE)
                        views.setViewPadding(R.id.appointment_title, dpToPx(16), 0, 0, 0)
                        views.setInt(R.id.task_checkbox_inner, "setColorFilter", currentAppointment.foregroundColor(context))

                        // set fill intent
                        val fillInIntent = Intent()
                        fillInIntent.data = Uri.parse("com.wavetogether.fillin://toggletaskstatus?id=${currentAppointment.id}&recurringTaskId=${currentAppointment.recurringTaskId ?: ""}&startAtMs=${currentAppointment.startAtMs}&endAtMs=${currentAppointment.endAtMs}")
                        views.setOnClickFillInIntent(R.id.task_checkbox, fillInIntent)
                    }
                }

                return views
            } catch (e: Exception) {
                e.printStackTrace()
                throw e
            }
        } catch (e: Exception) {
            e.printStackTrace()
            return RemoteViews(context.packageName, R.layout.task_item)
        }
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long = position.toLong()

    override fun hasStableIds(): Boolean = true
}