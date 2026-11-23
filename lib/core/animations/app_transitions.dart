// The page route and the bottom sheet that used to live here were duplicates
// of app_animations.dart (and the sheet had no callers). Bottom sheets and
// dialogs now open through routex_overlays.dart. Kept as a re-export so an old
// import keeps compiling; delete the file when nothing imports it.
export 'package:routex_mobile/core/animations/app_animations.dart'
    show FadeSlidePageRoute;
