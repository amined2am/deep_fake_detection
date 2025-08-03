plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mycompany.deepfakedetection"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.mycompany.deepfakedetection"
        minSdk = 23
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    signingConfigs {
        create("release") {
            // Décommente si tu utilises un keystore custom pour release
            // keyAlias = "xxx"
            // keyPassword = "xxx"
            // storeFile = file("xxx")
            // storePassword = "xxx"
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug") // Utilise la clé debug par défaut pour release (dev)
            isMinifyEnabled = false
            isShrinkResources = false // <-- Ajouté pour corriger l'erreur
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false // <-- Ajouté aussi pour debug
        }
    }
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.8.22")
    implementation(platform("com.google.firebase:firebase-bom:33.16.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.android.gms:play-services-auth:21.1.0")
}

// Bloc Flutter obligatoire
flutter {
    source = "../.."
}
