import java.util.Properties
import java.io.FileInputStream

// This block should ideally be outside the 'android' block, at the top level of the build.gradle.kts file.
// It sets up the keystore properties that will be used by the signingConfigs.
val keystoreProperties = Properties()
val keyPropertiesFile = rootProject.file("key.properties")
if (keyPropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keyPropertiesFile))
} else {
    // It's good practice to throw an error if the file is missing, especially for release builds.
    throw GradleException("key.properties not found! Please create it in the 'android' directory of your Flutter project and add your signing information.")
}


plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.unity.brevity"
    compileSdk = flutter.compileSdkVersion

    // Combine all top-level android configurations here
    // ndkVersion = "27.0.12077973"
    ndkVersion = "27.3.13750724"

    // Java compatibility
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    // Kotlin compatibility - only one block needed
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    signingConfigs {
        create("release") { // Use 'create("name")' for Kotlin DSL to define a new config
            // *** THE FIX IS HERE: Add .toString() and handle potential nulls ***
            storeFile = file(keystoreProperties["storeFile"] as String) // Cast directly as String
            storePassword = keystoreProperties["storePassword"] as String // Cast directly as String
            keyAlias = keystoreProperties["keyAlias"] as String // Cast directly as String
            keyPassword = keystoreProperties["keyPassword"] as String // Cast directly as String
        }
    }

    buildTypes {
        getByName("release") { // Use getByName("release") to configure the default release build type
            signingConfig = signingConfigs.getByName("release") // Assign the defined signing config

            // Existing release configurations should go here
            isMinifyEnabled = false // Consider setting to true for release builds for smaller APKs
            isShrinkResources = false // Consider setting to true for release builds
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
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