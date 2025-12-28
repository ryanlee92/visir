package com.wavetogether.fillin

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.res.Configuration
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*

class UpcomingWidgetProvider : AppWidgetProvider() {
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
            ComponentName(context, UpcomingWidgetProvider::class.java)
        )
        onUpdate(context, appWidgetManager, appWidgetIds)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == "com.wavetogether.fillin.home_widget.TOUCH") {
            val uri = intent.data
            if (uri?.host == "toggletaskstatus") {
                val taskId = uri.getQueryParameter("id")
                val recurringTaskId = uri.getQueryParameter("recurringTaskId")
                val startAtMs = uri.getQueryParameter("startAtMs")
                val endAtMs = uri.getQueryParameter("endAtMs")
                if (taskId != null) {
                    // 위젯 데이터 업데이트
                    val widgetData = HomeWidgetPlugin.getData(context)
                    val appointmentsJson = widgetData.getString("dateGroupedAppointments", "{}")
                    
                    if (appointmentsJson != "{}") {
                        try {
                            val jsonObject = JSONObject(appointmentsJson)
                            val keys = jsonObject.keys()
                            var found = false
                            
                            while (keys.hasNext()) {
                                val dateKey = keys.next()
                                val dateData = jsonObject.getJSONObject(dateKey)
                                val appointmentsArray = dateData.getJSONArray("appointments")
                                
                                for (i in 0 until appointmentsArray.length()) {
                                    val appointment = appointmentsArray.getJSONObject(i)
                                    val currentId = appointment.getString("id")
                                    
                                    if (currentId == taskId) {
                                        appointment.put("isDone", true)
                                        found = true
                                        break
                                    }
                                }
                                if (found) break
                            }
                            
                            // 업데이트된 데이터 저장
                            val updatedJson = jsonObject.toString()
                            widgetData.edit().putString("dateGroupedAppointments", updatedJson).apply()
                            
                            // 위젯 새로고침
                            val appWidgetManager = AppWidgetManager.getInstance(context)
                            
                            // TaskWidget 업데이트
                            val taskWidgetIds = appWidgetManager.getAppWidgetIds(
                                android.content.ComponentName(context, TaskWidgetProvider::class.java)
                            )
                            appWidgetManager.notifyAppWidgetViewDataChanged(taskWidgetIds, R.id.appointment_list)
                            
                            // UpcomingWidget 업데이트
                            val upcomingWidgetIds = appWidgetManager.getAppWidgetIds(
                                android.content.ComponentName(context, UpcomingWidgetProvider::class.java)
                            )
                            appWidgetManager.notifyAppWidgetViewDataChanged(upcomingWidgetIds, R.id.appointment_list)
                        } catch (e: Exception) {
                            e.printStackTrace()
                        }
                    }

                    val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
                        context,
                        Uri.parse("com.wavetogether.fillin://toggletaskstatus?id=$taskId&recurringTaskId=$recurringTaskId&startAtMs=$startAtMs&endAtMs=$endAtMs")
                    )
                    backgroundIntent.send()
                }
            } else if(uri?.host == "moveToDate") {
                val date = uri.getQueryParameter("date")
                if (date != null) {
                    val pendingIntentWithData = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("com.wavetogether.fillin://moveToDate?date=$date"))
                    pendingIntentWithData.send()
                }
            }
        }
    }
    
    internal fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val widgetData = HomeWidgetPlugin.getData(context)
        val userEmail: String? = widgetData.getString("userEmail", null)
        val colors = VisirColorScheme.getColor(context)
        
        val today = Calendar.getInstance()
        val dateFormat = SimpleDateFormat("d", Locale.ENGLISH)
        val dayFormat = SimpleDateFormat("EEE", Locale.ENGLISH)

        val views = RemoteViews(context.packageName, R.layout.calendar_widget)
            .apply {
                val today = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(Date())
                val backgroundIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("com.wavetogether.fillin://moveToDate?date=$today")
                )
                setOnClickPendingIntent(R.id.widget_root, backgroundIntent)
            }
        views.setTextViewText(R.id.today_date, dateFormat.format(today.time))
        views.setTextViewText(R.id.today_day, dayFormat.format(today.time).uppercase())
        views.setInt(R.id.today_day, "setTextColor", colors.primary)
        views.setInt(R.id.today_date, "setTextColor", colors.onBackground)
        views.setInt(R.id.bgcolor, "setColorFilter", colors.background)

        if (userEmail.isNullOrEmpty()) {
            views.setInt(R.id.no_login_text, "setTextColor", colors.onBackground)
            views.setViewVisibility(R.id.no_login_text, android.view.View.VISIBLE)
            views.setViewVisibility(R.id.calendar_list_container, android.view.View.GONE)
            appWidgetManager.updateAppWidget(appWidgetId, views)
            return
        }
        
        views.setViewVisibility(R.id.no_login_text, android.view.View.GONE)
        views.setViewVisibility(R.id.calendar_list_container, android.view.View.VISIBLE)
        
        val intent = Intent(context, VisirWidgetAppointmentListView::class.java).apply {
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
            putExtra("isTaskWidget", false)
            data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
        }
        views.setRemoteAdapter(R.id.appointment_list, intent)
        val pendingIntentWithData = WidgetUtils.getPendingIntent(context, UpcomingWidgetProvider::class.java)
        views.setPendingIntentTemplate(R.id.appointment_list, pendingIntentWithData)

        appWidgetManager.updateAppWidget(appWidgetId, views)
        appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.appointment_list)
    }
}