package com.wavetogether.fillin

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import java.text.SimpleDateFormat
import java.util.*

class CalendarMonthWidgetProvider : AppWidgetProvider() {
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
        newOptions: android.os.Bundle
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        // Always update when widget size changes or night mode changes
        val currentNightMode = context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK
        if (currentNightMode != lastNightMode) {
            lastNightMode = currentNightMode
        }
        updateAppWidget(context, appWidgetManager, appWidgetId)
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        lastNightMode = context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(
            android.content.ComponentName(context, CalendarMonthWidgetProvider::class.java)
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
        
        val calendar = Calendar.getInstance()
        val monthFormat = SimpleDateFormat("MMMM", Locale.ENGLISH)
        val yearFormat = SimpleDateFormat("yyyy", Locale.getDefault())
        val weekdayFormat = SimpleDateFormat("EEE", Locale.ENGLISH)
        val dateFormat = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        
        val views = RemoteViews(context.packageName, R.layout.calendar_month_widget)
            .apply {
                // Month and year header (separate like iOS)
                val monthText = monthFormat.format(calendar.time)
                val yearText = yearFormat.format(calendar.time)
                setTextViewText(R.id.month_text, monthText)
                setTextColor(R.id.month_text, colors.onBackground)
                setTextViewText(R.id.year_text, yearText)
                setTextColor(R.id.year_text, colors.primary)
                
                // Weekday headers (SUN, MON, TUE, etc.)
                val weekdayLabels = arrayOf("SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT")
                val weekdayIds = arrayOf(
                    R.id.weekday_sun, R.id.weekday_mon, R.id.weekday_tue,
                    R.id.weekday_wed, R.id.weekday_thu, R.id.weekday_fri, R.id.weekday_sat
                )
                for (i in weekdayLabels.indices) {
                    setTextViewText(weekdayIds[i], weekdayLabels[i])
                    when (i) {
                        0 -> setTextColor(weekdayIds[i], colors.error) // Sunday
                        6 -> setTextColor(weekdayIds[i], colors.tertiary) // Saturday
                        else -> setTextColor(weekdayIds[i], colors.onBackground)
                    }
                }
                setViewVisibility(R.id.weekday_header, android.view.View.VISIBLE)
                
                // Widget root click
                val backgroundIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("com.wavetogether.fillin://switchtab?tab=calendar")
                )
                setOnClickPendingIntent(R.id.widget_root, backgroundIntent)
                
                // Background color
                setInt(R.id.bgcolor, "setColorFilter", colors.background)
            }

        if (userEmail.isNullOrEmpty()) {
            views.setInt(R.id.no_login_text, "setTextColor", colors.onBackground)
            views.setViewVisibility(R.id.no_login_text, android.view.View.VISIBLE)
            views.setViewVisibility(R.id.calendar_grid_container, android.view.View.GONE)
            appWidgetManager.updateAppWidget(appWidgetId, views)
            return
        }
        
        views.setViewVisibility(R.id.no_login_text, android.view.View.GONE)
        views.setViewVisibility(R.id.calendar_grid_container, android.view.View.VISIBLE)
        
        // Calculate widget height and cell height
        val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
        val widgetHeightDp = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0)
        val widgetWidthDp = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0)
        
        // Convert dp to pixels
        val density = context.resources.displayMetrics.density
        val widgetHeightPx = (widgetHeightDp * density).toInt()
        val widgetWidthPx = (widgetWidthDp * density).toInt()
        
        // Calculate available height for grid (widget height - header - padding)
        // Top padding: 14dp, Bottom padding: 12dp
        // Month header: ~20dp (16sp text + 4dp padding bottom)
        // Weekday header: ~14dp (10sp text + 4dp padding bottom)
        val topPaddingPx = (14 * density).toInt()
        val bottomPaddingPx = (12 * density).toInt()
        val monthHeaderHeightPx = (20 * density).toInt()
        val weekdayHeaderHeightPx = (14 * density).toInt()
        val gridAvailableHeightPx = widgetHeightPx - topPaddingPx - bottomPaddingPx - monthHeaderHeightPx - weekdayHeaderHeightPx
        
        // Calculate cell height (6 weeks, 7 columns)
        // No spacing between cells (spacing = 0dp)
        val cellHeightPx = gridAvailableHeightPx / 6
        
        // Set up calendar grid
        val intent = Intent(context, CalendarMonthWidgetService::class.java).apply {
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            putExtra("primary", colors.primary)
            putExtra("onBackground", colors.onBackground)
            putExtra("background", colors.background)
            putExtra("onInverseSurface", colors.onInverseSurface)
            putExtra("shadow", colors.shadow)
            putExtra("outline", colors.outline)
            putExtra("surfaceTint", colors.surfaceTint)
            putExtra("secondary", colors.secondary)
            putExtra("error", colors.error)
            putExtra("tertiary", colors.tertiary)
            putExtra("cellHeightPx", cellHeightPx)
            data = Uri.parse(this.toUri(Intent.URI_INTENT_SCHEME))
        }
        views.setRemoteAdapter(R.id.calendar_grid, intent)
        
        val pendingIntentTemplate = WidgetUtils.getPendingIntent(context, CalendarMonthWidgetProvider::class.java)
        views.setPendingIntentTemplate(R.id.calendar_grid, pendingIntentTemplate)

        appWidgetManager.updateAppWidget(appWidgetId, views)
        appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.calendar_grid)
    }
}

