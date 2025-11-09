plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter plugin should be applied last
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.bookswap_app"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.bookswap_app"
        minSdk = flutter.minSdkVersion
        targetSdk = 36 
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
