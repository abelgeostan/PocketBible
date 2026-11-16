# Flutter Proguard Rules for Release builds
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep SQLite and database plugins
-keep class com.tekartik.sqflite.** { *; }
-keep class androidx.sqlite.** { *; }

# Keep SharedPreferences plugin
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-dontwarn io.flutter.plugins.sharedpreferences.**

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Flutter Timezone
-keep class com.whelkhosting.flutter_timezone.** { *; }

# File Picker
-keep class com.mr.flutter.plugin.filepicker.** { *; }

# Plus plugins (Share, Wakelock)
-keep class dev.fluttercommunity.plus.** { *; }

# URL Launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

# Keep models and reflection
-dontwarn io.flutter.embedding.**
-dontwarn androidx.**
