plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "bo.mypets.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // 👈 En Kotlin DSL se usa "isCoreLibraryDesugaringEnabled"
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "bo.mypets.app"
        minSdk = flutter.minSdkVersion // 👈 Asegurar que sea 21 o superior
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // 👈 Agregar multiDexEnabled
        multiDexEnabled = true
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
    // 👈 Usar sintaxis de Kotlin DSL
    implementation(platform("com.google.firebase:firebase-bom:34.15.0"))
    
    // 👈 Agregar desugaring con sintaxis correcta
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    
    // 👈 Agregar multidex si es necesario
    implementation("androidx.multidex:multidex:2.0.1")
}
