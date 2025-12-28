package com.wavetogether.fillin

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build

object WidgetUtils {
    fun getPendingIntent(context: Context, providerClass: Class<*>): PendingIntent {
        val intent = Intent(context, providerClass)
        intent.action = "com.wavetogether.fillin.home_widget.TOUCH"

        var flags = PendingIntent.FLAG_UPDATE_CURRENT
        if (Build.VERSION.SDK_INT >= 23) {
            flags = flags or PendingIntent.FLAG_MUTABLE
        }

        return PendingIntent.getBroadcast(context, 0, intent, flags)
    }
} 