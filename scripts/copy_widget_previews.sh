#!/bin/bash

# Copy widget preview images from assets/widget to android/res/drawable
cp assets/widget/calendar_preview.png android/app/src/main/res/drawable/calendar_month_widget_preview.png
cp assets/widget/task_preview.png android/app/src/main/res/drawable/task_widget_preview.png
cp assets/widget/upcoming_preview.png android/app/src/main/res/drawable/upcoming_widget_preview.png

echo "Widget preview images copied successfully!"

