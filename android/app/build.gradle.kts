import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties().apply {
    val localPropertiesFile = rootProject.file("local.properties")
    if (localPropertiesFile.exists()) {
        localPropertiesFile.reader(Charsets.UTF_8).use { reader -> load(reader) }
    }
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"

android {
    namespace = "com.topon.flutter.demo"
    compileSdk = 35
    ndkVersion = "28.2.13676358"

    defaultConfig {
        applicationId = "com.topon.flutter.demo"
        minSdk = 24
        targetSdk = 35
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
        multiDexEnabled = true
    }

    dexOptions {
        javaMaxHeapSize = "4g"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.android.support:appcompat-v7:28.0.0")
    implementation("com.anythink.sdk:debugger-ui-tpn:1.1.2")

    // Anythink (Necessary)
    api("com.anythink.sdk:core-tpn:6.5.38")
    api("com.anythink.sdk:nativead-tpn:6.5.38")
    api("com.anythink.sdk:banner-tpn:6.5.38")
    api("com.anythink.sdk:interstitial-tpn:6.5.38")
    api("com.anythink.sdk:rewardedvideo-tpn:6.5.38")
    api("com.anythink.sdk:splash-tpn:6.5.38")
    api("com.anythink.sdk:dm-vp-tpn:6.5.38")

    // Androidx (Necessary)
    api("androidx.appcompat:appcompat:1.6.1")
    api("androidx.browser:browser:1.4.0")

    // Anythink Adx SDK (Necessary)
    api("com.anythink.sdk:adapter-tpn-sdm:6.5.38")
    api("com.smartdigimkttech.sdk:smartdigimkttech-sdk:6.5.48")
}
