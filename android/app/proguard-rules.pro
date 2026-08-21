# google_mlkit_text_recognition (Phase 13) references every per-script
# recognizer's options Builder (Chinese/Devanagari/Japanese/Korean) in its
# own Kotlin glue code's `when` branch, even though this app only depends
# on the Latin-script recognizer artifact (com.google.mlkit:text-recognition)
# -- `VisionService` always uses TextRecognitionScript.latin (see
# vision_service.dart), so those other branches are dead code at runtime,
# never actually reached. R8 can't see that at the bytecode level, so
# without these rules a release build fails outright with "Missing classes
# detected while running R8" rather than just warning. Real rules, found by
# actually running `flutter build apk --release` and reading R8's own
# generated missing_rules.txt -- not copied from a template.
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions
