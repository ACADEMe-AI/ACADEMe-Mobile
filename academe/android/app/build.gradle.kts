import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreFile = rootProject.file("key.properties")
val hasReleaseKey = keystoreFile.exists()
val keystoreProperties = Properties().apply {
    if (hasReleaseKey) keystoreFile.inputStream().use { load(it) }
}

gradle.taskGraph.whenReady {
    if (!hasReleaseKey && allTasks.any { it.name == "bundleRelease" }) {
        throw GradleException(
            "android/key.properties is missing, so this bundle would be " +
                "signed with the debug key and Play would reject it. Add " +
                "android/key.properties with storeFile, storePassword, " +
                "keyAlias and keyPassword, then build the bundle again.",
        )
    }
}

android {
    namespace = "com.academe.flutter_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.academe.flutter"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName(if (hasReleaseKey) "release" else "debug")
        }
    }
}

flutter {
    source = "../.."
}

configurations.configureEach {
    exclude(group = "com.google.android.gms", module = "play-services-ads-identifier")
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
