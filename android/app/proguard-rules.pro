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

# Keep models and reflection
-dontwarn io.flutter.embedding.**
-dontwarn androidx.**
