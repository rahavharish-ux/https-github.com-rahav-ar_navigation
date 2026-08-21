import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Phase 11: real Google Maps SDK key, read from local.properties (already
// gitignored — see android/.gitignore) rather than hardcoded here, so a
// real key never lands in version control. Falls back to an obvious
// placeholder if local.properties has no MAPS_API_KEY entry yet.
val localProperties = Properties().apply {
    val localPropertiesFile = rootProject.file("local.properties")
    if (localPropertiesFile.exists()) {
        localPropertiesFile.inputStream().use { load(it) }
    }
}
val mapsApiKey: String =
    localProperties.getProperty("MAPS_API_KEY") ?: "YOUR_GOOGLE_MAPS_API_KEY_HERE"

// Phase 17: real release signing, read from key.properties (already
// gitignored — see android/.gitignore, along with **/*.jks) rather than
// hardcoded here. Falls back to debug signing (this project's prior
// state) if key.properties/the keystore it points to don't exist yet —
// same graceful-degradation pattern as mapsApiKey above — so a fresh
// clone without the real keystore still builds.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseSigning =
    keystorePropertiesFile.exists() &&
        run {
            keystoreProperties.load(FileInputStream(keystorePropertiesFile))
            file(keystoreProperties.getProperty("storeFile")).exists()
        }

android {
    namespace = "com.tnarnav.tn_ar_navigation"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.tnarnav.tn_ar_navigation"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["mapsApiKey"] = mapsApiKey
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            // Real release signing (Phase 17) when key.properties/the
            // keystore it points to exist; falls back to the debug
            // keystore otherwise (this project's prior state, and what a
            // fresh clone without the real keystore still gets) so
            // `flutter run --release` keeps working either way.
            signingConfig = signingConfigs.getByName(
                if (hasReleaseSigning) "release" else "debug",
            )
            // R8 minification/shrinking is on by default for release
            // builds via Flutter's own tooling (Phase 16 found this by
            // actually running `flutter build apk --release`, not by
            // assuming) -- proguard-rules.pro adds the real keep/dontwarn
            // rules that were missing (google_mlkit_text_recognition's
            // unused per-script recognizer classes), without which a
            // release build fails outright.
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Google's real ARCore SDK (Phase 10) -- talked to directly via a
    // MethodChannel in MainActivity.kt, not through a third-party Flutter
    // AR plugin. See PROJECT_STATUS.md Phase 10 for why: the community
    // Flutter ARCore plugin ecosystem was unmaintained/unproven when this
    // phase was built.
    implementation("com.google.ar:core:1.54.0")
}
