# Keep Tink crypto classes (for Zoom SDK encrypted prefs)
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**

# Keep Zoom SDK classes
-keep class us.zoom.** { *; }
-dontwarn us.zoom.**

# Keep WorkManager classes (for release builds with code shrinking)
-keep class androidx.work.impl.WorkManagerInitializer { *; }
-keep class androidx.startup.InitializationProvider { *; }

# Keep Glide classes (for image loading used by Zoom SDK)
-keep public class * implements com.bumptech.glide.module.GlideModule
-keep class * extends com.bumptech.glide.module.AppGlideModule {
 <init>(...);
}
-keep public enum com.bumptech.glide.load.ImageHeaderParser$** {
  **[] $VALUES;
  public *;
}
-keep class com.bumptech.glide.load.data.ParcelFileDescriptorRewinder$InternalRewinder {
  *** rewind();
}

# Keep RxJava3 (required by Zoom SDK)
-keep class io.reactivex.rxjava3.** { *; }
-dontwarn io.reactivex.rxjava3.**
