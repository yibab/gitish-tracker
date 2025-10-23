package com.example.gitish_tracker

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import com.example.gitish_tracker.R
import es.antonborri.home_widget.HomeWidgetPlugin
import java.io.File

class HeatmapWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.heatmap_widget)

            val imagePath = widgetData.getString("image_path", null)
            if (imagePath != null) {
                val imageFile = File(imagePath)
                if (imageFile.exists()) {
                    val bitmap = BitmapFactory.decodeFile(imageFile.absolutePath)
                    views.setImageViewBitmap(R.id.widget_image, bitmap)
                }
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
