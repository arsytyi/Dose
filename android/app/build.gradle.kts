import java.util.Base64

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "app.bady.bady"
    compileSdk = maxOf(flutter.compileSdkVersion, 37)
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // Fixed forever once the app is on Google Play. (The Kotlin
        // namespace stays app.bady.bady; users never see it.)
        applicationId = "app.dose.reminder"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Release signing: a fixed key lets new versions install over old ones.
    // CI passes the keystore via the BADY_KEYSTORE_BASE64 and
    // BADY_KEYSTORE_PASSWORD secrets; without them the debug key is used.
    val keystoreB64 = System.getenv("BADY_KEYSTORE_BASE64")
    val keystorePassword = System.getenv("BADY_KEYSTORE_PASSWORD")
    val hasReleaseKey = !keystoreB64.isNullOrBlank() && !keystorePassword.isNullOrBlank()

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                val file = layout.buildDirectory.file("bady-release.jks").get().asFile
                file.parentFile.mkdirs()
                file.writeBytes(Base64.getMimeDecoder().decode(keystoreB64!!.trim()))
                storeFile = file
                storePassword = keystorePassword!!.trim()
                keyAlias = "bady"
                keyPassword = keystorePassword.trim()
            }
        }
    }

    // play: Google Play build (no network, updates come from Play).
    // github: APK for GitHub Releases, can check GitHub for a newer version.
    flavorDimensions += "store"
    productFlavors {
        create("play") { dimension = "store" }
        create("github") { dimension = "store" }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName(if (hasReleaseKey) "release" else "debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
