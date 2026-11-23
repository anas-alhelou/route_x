# Release shrinking (R8). Flutter adds its own rules; these cover plugins that
# read classes by reflection.

# flutter_local_notifications stores scheduled notifications with Gson.
-keep class com.dexterous.** { *; }
-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod

# Firebase / Google Play services keep their own consumer rules; keep the
# model classes used for messaging payloads.
-keep class com.google.firebase.messaging.** { *; }

# Do not warn about optional classes referenced by dependencies.
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
