package com.example.daily_manwon

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews

/// 고양이 캐릭터 홈 위젯 — cat_mood 값에 따라 이미지와 텍스트를 갱신한다
class BudgetCatWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        private const val PREFS_NAME = "home_widget_prefs"
        private const val KEY_CAT_MOOD = "cat_mood"

        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
        ) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val catMood = prefs.getString(KEY_CAT_MOOD, "comfortable") ?: "comfortable"

            val (drawableRes, moodLabel) = when (catMood) {
                "comfortable" -> Pair(R.drawable.cat_comfortable, "여유")
                "normal" -> Pair(R.drawable.cat_normal, "보통")
                "danger" -> Pair(R.drawable.cat_danger, "위험")
                "over" -> Pair(R.drawable.cat_over, "초과")
                else -> Pair(R.drawable.cat_comfortable, "여유")
            }

            val views = RemoteViews(context.packageName, R.layout.budget_cat_widget)
            views.setImageViewResource(R.id.cat_image, drawableRes)
            views.setTextViewText(R.id.mood_text, moodLabel)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
