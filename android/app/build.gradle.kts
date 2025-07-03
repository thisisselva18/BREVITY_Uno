import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
keystoreProperties.load(FileInputStream(rootProject.file("key.properties")))

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.unity.brevity"
    compileSdk = flutter.compileSdkVersion
    android {
        // ...
        compileSdk = flutter.compileSdkVersion
        ndkVersion = "27.0.12077973"

        // Java compatibility
        compileOptions {
            sourceCompatibility = JavaVersion.VERSION_11
            targetCompatibility = JavaVersion.VERSION_11
        }

        // Kotlin compatibility
        kotlinOptions {
            jvmTarget = JavaVersion.VERSION_11.toString()
        }

        // ... rest of your config ...
        ndkVersion = "27.0.12077973"
    }
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.unity.brevity"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
}

flutter {
    source = "../.."
}
