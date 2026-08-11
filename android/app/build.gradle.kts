plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "sn.lic.woutalma_keur"
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
        applicationId = "sn.lic.woutalma_keur"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Isar livre ses bibliothèques natives pour trois ABI. `flutter build
        // --target-platform` ne filtre que les siennes : sans ce filtre, un APK
        // arm64 embarque quand même 2,3 Mo de binaires armeabi-v7a et x86_64
        // qui ne s'exécuteront jamais sur la cible.
        ndk {
            abiFilters += listOf("arm64-v8a")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // `abiFilters` ne filtre pas les `.so` livrés par les AAR des plugins :
    // Isar embarque les siens pour armeabi-v7a et x86_64, soit 2,3 Mo qui ne
    // s'exécuteront jamais sur un APK arm64. Ici on les exclut de l'empaquetage.
    packaging {
        jniLibs {
            excludes += setOf("lib/armeabi-v7a/**", "lib/x86_64/**", "lib/x86/**")
        }
    }
}

flutter {
    source = "../.."
}
