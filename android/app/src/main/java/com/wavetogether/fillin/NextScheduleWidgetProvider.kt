package com.wavetogether.fillin

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.graphics.Color
import android.net.Uri
import android.os.Bundle
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*

class NextScheduleWidgetProvider : AppWidgetProvider() {
    private var lastNightMode: Int = 0

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        val currentNightMode = context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK
        if (currentNightMode != lastNightMode) {
            lastNightMode = currentNightMode
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        lastNightMode = context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(
            ComponentName(context, NextScheduleWidgetProvider::class.java)
        )
        onUpdate(context, appWidgetManager, appWidgetIds)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
    }

    internal fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val widgetData = HomeWidgetPlugin.getData(context)
        val userEmail: String? = widgetData.getString("userEmail", null)
        val colors = VisirColorScheme.getColor(context)
        
        val views = RemoteViews(context.packageName, R.layout.next_schedule_widget)
            .apply {
                val today = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(Date())
                val backgroundIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("com.wavetogether.fillin://moveToDate?date=$today")
                )
                setOnClickPendingIntent(R.id.widget_root, backgroundIntent)
            }
        
        views.setInt(R.id.bgcolor, "setColorFilter", colors.background)

        if (userEmail.isNullOrEmpty()) {
            views.setInt(R.id.no_login_text, "setTextColor", colors.onBackground)
            views.setViewVisibility(R.id.no_login_text, android.view.View.VISIBLE)
            views.setViewVisibility(R.id.content_container, android.view.View.GONE)
            appWidgetManager.updateAppWidget(appWidgetId, views)
            return
        }
        
        views.setViewVisibility(R.id.no_login_text, android.view.View.GONE)
        views.setViewVisibility(R.id.content_container, android.view.View.VISIBLE)
        
        // Load next schedule data
        val nextScheduleJson = widgetData.getString("nextSchedule", "")
        
        if (nextScheduleJson.isEmpty()) {
            views.setViewVisibility(R.id.content_container, android.view.View.GONE)
            views.setViewVisibility(R.id.no_login_text, android.view.View.VISIBLE)
            views.setTextViewText(R.id.no_login_text, "No upcoming schedule")
            views.setInt(R.id.no_login_text, "setTextColor", colors.onBackground)
            appWidgetManager.updateAppWidget(appWidgetId, views)
            return
        }
        
        try {
            val nextSchedule = JSONObject(nextScheduleJson)
            
            // Event title
            val title = nextSchedule.optString("title", "Untitled")
            views.setTextViewText(R.id.event_title, title)
            views.setInt(R.id.event_title, "setTextColor", colors.onBackground)
            
            // Color bar
            val colorInt = nextSchedule.optInt("colorInt", 0)
            val colorBar = android.graphics.Color.argb(
                (colorInt shr 24) and 0xFF,
                (colorInt shr 16) and 0xFF,
                (colorInt shr 8) and 0xFF,
                colorInt and 0xFF
            )
            views.setInt(R.id.color_bar, "setBackgroundColor", colorBar)
            
            // Event details
            val startTimeMs = nextSchedule.optLong("startTimeMs", 0)
            val duration = nextSchedule.optInt("duration", 0)
            val projectName = nextSchedule.optString("projectName", "")
            val calendarName = nextSchedule.optString("calendarName", "")
            
            val startDate = Date(startTimeMs)
            val dateFormatter = SimpleDateFormat("EEE, MMM d, yyyy h:mm a", Locale.ENGLISH)
            val dateString = dateFormatter.format(startDate)
            
            val typeString = if (projectName.isNotEmpty()) projectName else calendarName
            val detailsText = "$dateString • $duration min • $typeString"
            views.setTextViewText(R.id.event_details, detailsText)
            views.setInt(R.id.event_details, "setTextColor", colors.inverseSurface)
            
            // Previous Context
            val previousContext = nextSchedule.optJSONObject("previousContext")
            if (previousContext != null) {
                val summary = previousContext.optString("summary", "")
                if (summary.isNotEmpty()) {
                    views.setViewVisibility(R.id.previous_context_container, android.view.View.VISIBLE)
                    views.setTextViewText(R.id.previous_context_text, summary)
                    views.setInt(R.id.previous_context_title, "setTextColor", colors.onBackground)
                    views.setInt(R.id.previous_context_text, "setTextColor", colors.onBackground)
                    // Set background color to surface with 0.5 alpha
                    val surfaceColor = colors.surface
                    val surfaceColorWithAlpha = Color.argb(
                        (Color.alpha(surfaceColor) * 0.5).toInt(),
                        Color.red(surfaceColor),
                        Color.green(surfaceColor),
                        Color.blue(surfaceColor)
                    )
                    views.setInt(R.id.previous_context_container, "setBackgroundColor", surfaceColorWithAlpha)
                } else {
                    views.setViewVisibility(R.id.previous_context_container, android.view.View.GONE)
                }
            } else {
                views.setViewVisibility(R.id.previous_context_container, android.view.View.GONE)
            }
            
            // Location - removed
            views.setViewVisibility(R.id.location_container, android.view.View.GONE)
            
        } catch (e: Exception) {
            e.printStackTrace()
            views.setViewVisibility(R.id.content_container, android.view.View.GONE)
            views.setViewVisibility(R.id.no_login_text, android.view.View.VISIBLE)
            views.setTextViewText(R.id.no_login_text, "Error loading schedule")
            views.setInt(R.id.no_login_text, "setTextColor", colors.onBackground)
        }
        
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}

