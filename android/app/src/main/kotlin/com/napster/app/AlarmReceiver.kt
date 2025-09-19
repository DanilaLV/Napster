package com.napster.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.core.content.ContextCompat

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val alarmId = intent.getStringExtra("alarm_id") ?: return
        Log.d("Napster", "Alarm fired: $alarmId")
        val serviceIntent = Intent(context, NapForegroundService::class.java).apply {
            putExtra("alarm_id", alarmId)
        }
        ContextCompat.startForegroundService(context, serviceIntent)
    }
}
