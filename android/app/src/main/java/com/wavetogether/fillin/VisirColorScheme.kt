package com.wavetogether.fillin

import android.content.Context
import android.content.res.Configuration
import android.graphics.Color
import es.antonborri.home_widget.HomeWidgetPlugin

data class VisirColorScheme(
    val background: Int,
    val onBackground: Int,
    val outline: Int,
    val shadow: Int,
    val onInverseSurface: Int,
    val surfaceTint: Int,
    val primary: Int,
    val secondary: Int,
    val error: Int,
    val tertiary: Int
) {
    companion object {
        private val lightColors = VisirColorScheme(
            background = Color.parseColor("#FFFFFF"),
            onBackground = Color.parseColor("#000000"),
            outline = Color.parseColor("#EBEBED"),
            shadow = Color.parseColor("#3A3A3C"),
            onInverseSurface = Color.parseColor("#48484A"),
            surfaceTint = Color.parseColor("#8E8E91"),
            primary = Color.parseColor("#7C5DFF"),
            secondary = Color.parseColor("#5d85ff"),
            error = Color.parseColor("#ff5d5d"),
            tertiary = Color.parseColor("#7b86c4")
        )
        
        private val darkColors = VisirColorScheme(
            background = Color.parseColor("#1E1E1E"),
            onBackground = Color.parseColor("#FFFFFF"),
            outline = Color.parseColor("#2C2C2E"),
            shadow = Color.parseColor("#DBDBE0"),
            onInverseSurface = Color.parseColor("#BDBDC2"),
            surfaceTint = Color.parseColor("#636366"),
            primary = Color.parseColor("#7C5DFF"),
            secondary = Color.parseColor("#5d85ff"),
            error = Color.parseColor("#ff5d5d"),
            tertiary = Color.parseColor("#7b86c4")
        )
        
        fun getColor(context: Context): VisirColorScheme {
            val widgetData = HomeWidgetPlugin.getData(context)
            val themeMode = widgetData.getString("themeMode", "system")
            
            return when (themeMode) {
                "light" -> lightColors
                "dark" -> darkColors
                else -> { // system
                    val isDarkMode = context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK == Configuration.UI_MODE_NIGHT_YES
                    if (isDarkMode) darkColors else lightColors
                }
            }
        }
    }
} 