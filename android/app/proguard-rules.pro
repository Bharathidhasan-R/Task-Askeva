# Flutter ProGuard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Suppress Play Core / Deferred components warnings
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Google & Guava / J2ObjC / Annotations warnings
-dontwarn com.google.j2objc.annotations.**
-dontwarn com.google.j2objc.annotations.RetainedWith
-dontwarn javax.annotation.**
-dontwarn org.checkerframework.**
-dontwarn com.google.errorprone.annotations.**
-dontwarn org.codehaus.mojo.animal_sniffer.**
-dontwarn com.google.common.**

# Networking & Storage
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn retrofit2.**

# General
-dontwarn **
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod
