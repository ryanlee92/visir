package com.wavetogether.fillin

import android.content.Context
import android.content.res.Configuration
import android.graphics.Color
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONObject

data class Appointment(
    val id: String,
    val title: String,
    val colorInt: Int,
    val startAtMs: Long,
    val endAtMs: Long,
    val isAllDay: Boolean,
    val isDone: Boolean,
    val recurringTaskId: String?,
    val isEvent: Boolean
) {
    private fun isDarkMode(context: Context): Boolean {
        val widgetData = HomeWidgetPlugin.getData(context)
        val themeMode = widgetData.getString("themeMode", "system")
        
        return when (themeMode) {
            "light" -> false
            "dark" -> true
            else -> context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK == Configuration.UI_MODE_NIGHT_YES
        }
    }

    private fun getHSV(color: Int): FloatArray {
        val hsv = FloatArray(3)
        Color.colorToHSV(color, hsv)
        return hsv
    }

    private fun HSVToColor(hsv: FloatArray, alpha: Int = 255): Int {
        return Color.HSVToColor(alpha, hsv)
    }

    private fun _baseBackgroundColor(context: Context): Int {
        val hsv = getHSV(colorInt)
        
        if (!isDarkMode(context)) {
            if (hsv[2] > 0.7f && hsv[1] >= 0.2f && hsv[1] < 0.5f) {
                hsv[2] = 0.7f
            } else if (hsv[2] > 0.5f && hsv[1] < 0.2f) {
                hsv[2] = 0.5f
            } else if (hsv[2] > 0.9f && hsv[1] >= 0.5f) {
                hsv[2] = 0.9f
            }
        }
        
        return HSVToColor(hsv)
    }

    fun backgroundColor(context: Context): Int {
        val baseColor = _baseBackgroundColor(context)
        val hsv = getHSV(baseColor)
        val alpha = if (hsv[2] <= 0.6f && isDarkMode(context)) 77 else 38 // 0.3 -> 77, 0.15 -> 38
        return Color.argb(alpha, Color.red(baseColor), Color.green(baseColor), Color.blue(baseColor))
    }

    fun foregroundColor(context: Context): Int {
        val hsv = getHSV(_baseBackgroundColor(context))
        
        if (isDarkMode(context) && hsv[2] <= 0.6f) {
            hsv[2] = 0.9f
        }
        
        return HSVToColor(hsv)
    }

    fun textColor(context: Context): Int {
        val hsv = getHSV(_baseBackgroundColor(context))
        
        if (isDarkMode(context)) {
            if (hsv[2] <= 0.6f) {
                hsv[2] = 0.9f
            }
            hsv[1] = 0.1f
            hsv[2] = 1.0f
        } else {
            if (hsv[0] > 0.4f && hsv[0] < 0.95f && hsv[2] > 0.7f && hsv[1] >= 0.5f) {
                hsv[2] = 0.7f
            }
            hsv[1] = 0.95f
            hsv[2] = 0.3f
        }
        
        return HSVToColor(hsv)
    }
}

fun parseAppointment(json: JSONObject): Appointment {
    return Appointment(
        id = json.optString("id", "").toString(),
        title = json.optString("title", "").toString(),
        colorInt = json.getInt("colorInt"),
        startAtMs = json.optLong("startAtMs"),
        endAtMs = json.optLong("endAtMs"),
        isAllDay = json.getBoolean("isAllDay"),
        isDone = json.getBoolean("isDone"),
        recurringTaskId = json.optString("recurringTaskId", null).let { if (it == "null" || it.isEmpty()) null else it },
        isEvent = json.getBoolean("isEvent")
    )
} 