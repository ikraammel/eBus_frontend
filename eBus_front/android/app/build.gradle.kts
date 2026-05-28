/**
 * Android build configuration for the Smart Bus application module.
 * This file uses the Kotlin DSL (build.gradle.kts) to define the project's build settings,
 * plugins, and dependencies.
 */
plugins {
    // Standard Android application plugin to build the Android app.
    id("com.android.application")
    // Kotlin plugin for Android support.
    id("kotlin-android")
    /**
     * The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
     * It handles the integration of the Flutter project into the Android build process.
     */
    id("dev.flutter.flutter-gradle-plugin")
    // Google Services plugin for Firebase integration.
    id("com.google.gms.google-services")
}

android {
    /**
     * The namespace is used for the generated R and BuildConfig classes.
     * It should be unique and typically matches the package name.
     */
    namespace = "com.example.smart_bus"
    
    /**
     * SDK versions are managed by the Flutter Gradle plugin.
     * These values are typically derived from your project settings or local.properties.
     */
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        /**
         * Sets the Java language level for source and target compatibility.
         * Java 17 is standard for modern Android and Flutter development.
         */
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        /**
         * Ensures that the Kotlin compiler generates bytecode compatible with JVM 17.
         */
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        /**
         * The unique identifier for the application on the Google Play Store and the device.
         * TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
         */
        applicationId = "com.example.smart_bus"
        
        /**
         * SDK versions and app versioning information are synchronized with the settings in the Flutter project.
         * For more information, see: https://flutter.dev/to/review-gradle-config.
         */
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        /**
         * Configuration for the release build of the application.
         */
        release {
            // TODO: Add your own signing config for the release build.
            /**
             * Currently using debug keys for the release build to allow `flutter run --release`
             * to function during development without a production signing key.
             */
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    /**
     * Import the Firebase Bill of Materials (BoM).
     * The BoM allows you to manage all Firebase library versions by specifying only one version (the BoM version).
     * https://firebase.google.com/docs/android/learn-more#bom
     */
    implementation(platform("com.google.firebase:firebase-bom:34.12.0"))

    /**
     * Firebase Realtime Database dependency.
     */
    implementation("com.google.firebase:firebase-database")
    
    // TODO: Add the dependencies for Firebase products you want to use
    // When using the BoM, don't specify versions in Firebase dependencies
    
    /**
     * Firebase Analytics for tracking app usage and user engagement.
     */
    implementation("com.google.firebase:firebase-analytics")


    // Add the dependencies for any other desired Firebase products
    // https://firebase.google.com/docs/android/setup#available-libraries
}

flutter {
    /**
     * Specifies the path to the root directory of the Flutter project relative to this script.
     */
    source = "../.."
}
