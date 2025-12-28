package com.wavetogether.fillin

import android.content.Context
import android.content.res.Configuration
import android.graphics.Color
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONObject

data class Inbox(
    val id: String,
    val title: String,
    val providerIcon: String,
    val providerName: String,
    val timeString: String,
    val messageUserName: String?
)

fun parseInbox(json: JSONObject): Inbox {
    return Inbox(
        id = json.optString("id", "").toString(),
        title = json.optString("title", "").toString(),
        providerIcon = json.optString("providerIcon", "").toString(),
        providerName = json.optString("providerName", "").toString(),
        timeString = json.optString("timeString", "").toString(),
        messageUserName = json.optString("messageUserName", null)
    )
}
