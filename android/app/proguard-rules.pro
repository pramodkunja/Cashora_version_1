# Flutter Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase Rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.internal.** { *; }
-keep class com.google.android.gms.tasks.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Prevent warnings for missing Play Core classes (used by Flutter internally for deferred components)
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.gms.**
-dontwarn com.google.firebase.**

# Prevent obfuscation of R classes to keep resource IDs stable
-keep class **.R$* {
    <fields>;
}
