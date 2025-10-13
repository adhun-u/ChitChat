# Rules to prevent ProGuard/R8 from stripping classes needed by just_audio
-keep class com.ryanheise.just_audio.* { *; }
-keep class androidx.media.* { *; }
-keep class androidx.media3.* { *; }

# Also helpful for method channels in general
-keepnames class * {
    @io.flutter.plugin.common.MethodCall <init>(...);
}