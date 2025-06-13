import java.io.File
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
// POPRAWIONA ŚCIEŻKA - teraz szuka w android/app/key.properties
val keystorePropertiesFile = File(projectDir, "key.properties")
println("DEBUG CWD: " + projectDir)
println("DEBUG FILE: " + keystorePropertiesFile.absolutePath)
println("DEBUG EXISTS: " + keystorePropertiesFile.exists())

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
} else {
    throw GradleException("Brak pliku key.properties! Upewnij się, że plik istnieje.")
}

// Wymuszamy obecność kluczy i ich niepustość
listOf("keyAlias", "keyPassword", "storeFile", "storePassword").forEach { key ->
    if (!keystoreProperties.containsKey(key) || (keystoreProperties[key] as? String).isNullOrBlank()) {
        throw GradleException("Brakuje wartości $key w key.properties!")
    }
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "pl.dlaroslin.app"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "pl.dlaroslin.app"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false // 
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
        getByName("debug") {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.10.1")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.9.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
}
