package dev.josh.oncard

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.widget.RemoteViews

/**
 * The Oncard home-screen widget: streak, due today, a heatmap of the
 * last weeks and the top decks. Data is written by the Flutter side
 * through the home_widget plugin into HomeWidgetPreferences.
 */
class OncardWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs = context.getSharedPreferences(
            "HomeWidgetPreferences", Context.MODE_PRIVATE)
        for (id in appWidgetIds) {
            val views = RemoteViews(
                context.packageName, R.layout.oncard_widget)

            views.setTextViewText(
                R.id.widget_streak,
                (prefs.getString("streak", "0") ?: "0") + " day streak")
            views.setTextViewText(
                R.id.widget_due,
                (prefs.getString("due", "0") ?: "0") + " due today")

            val heatPath = prefs.getString("heatmapPath", null)
            if (heatPath != null) {
                try {
                    val bitmap = BitmapFactory.decodeFile(heatPath)
                    if (bitmap != null) {
                        views.setImageViewBitmap(R.id.widget_heatmap, bitmap)
                    }
                } catch (_: IllegalArgumentException) {
                    // Corrupt image: keep whatever the layout shows.
                }
            }

            val deckIds = intArrayOf(
                R.id.widget_deck0, R.id.widget_deck1, R.id.widget_deck2)
            for (i in deckIds.indices) {
                val line = prefs.getString("deck" + i, null)
                views.setTextViewText(deckIds[i], line ?: "")
            }

            val launch = context.packageManager
                .getLaunchIntentForPackage(context.packageName)
            if (launch != null) {
                val pending = PendingIntent.getActivity(
                    context,
                    0,
                    launch,
                    PendingIntent.FLAG_IMMUTABLE or
                        PendingIntent.FLAG_UPDATE_CURRENT)
                views.setOnClickPendingIntent(R.id.widget_root, pending)
            }

            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
