# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }

# TensorFlow
-keep class org.tensorflow.** { *; }
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }

# Play Core
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelables
-keep class * implements android.os.Parcelable {
    static ** CREATOR;
}

# Keep Serializable classes
-keepnames class * implements java.io.Serializable

# Keep R8 full mode
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes MethodParameters
-keepattributes RuntimeVisible*Annotations
-keepattributes RuntimeInvisible*Annotations
-keepattributes RuntimeVisibleParameter*Annotations
-keepattributes RuntimeInvisibleParameter*Annotations
-keepattributes AnnotationDefault
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes MethodParameters
-keepattributes RuntimeVisible*Annotations
-keepattributes RuntimeInvisible*Annotations
-keepattributes RuntimeVisibleParameter*Annotations
-keepattributes RuntimeInvisibleParameter*Annotations
-keepattributes AnnotationDefault
-renamesourcefileattribute SourceFile 