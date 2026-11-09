import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 구즉 release 서명 키. android/key.properties에 storeFile, storePassword, keyAlias, keyPassword를 적습니다.
// 이 파일과 키 파일은 git에 올리지 않습니다(android/.gitignore). 없으면 지금처럼 debug 키로 서명합니다.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        FileInputStream(keystorePropertiesFile).use { load(it) }
    }
}
val hasReleaseKey = keystorePropertiesFile.exists()

android {
    namespace = "com.example.gujeuk_check_in_flutter_v2"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.gujeuk_check_in_flutter_v2"
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

    flavorDimensions += "app"
    productFlavors {
        create("gujeuk") {
            dimension = "app"
            applicationIdSuffix = ".gujeuk"
            manifestPlaceholders["appName"] = "구즉 체크인"
            // 설치된 키오스크의 대기열이 사라지지 않게 applicationId는 바꾸지 않습니다.
            // 키가 있으면 release를 그 키로 서명합니다. debug 빌드는 build type의 debug 키를 씁니다.
            signingConfig = signingConfigs.getByName(if (hasReleaseKey) "release" else "debug")
        }
        create("bubdong") {
            dimension = "app"
            applicationIdSuffix = ".bubdong"
            manifestPlaceholders["appName"] = "법동 체크인"
            // 법동은 지금처럼 debug 키로 서명합니다.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    buildTypes {
        release {
            // 서명 키는 flavor마다 정합니다(productFlavors). build type에 두면 flavor 설정을 덮어씁니다.
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
