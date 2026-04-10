group = "com.dyplink.dyplink"
version = "0.0.1"

buildscript {
    val kotlinVersion = "2.2.20"
    repositories {
        google()
        mavenCentral()
        mavenLocal()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.11.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        // Pulls the locally-published dyplink-android-sdk artifacts.
        //
        // DEV WORKFLOW: before running the example app or a consumer app,
        // publish the native SDK to ~/.m2 via:
        //
        //   cd ../../dyplink-android-sdk
        //   ./gradlew publishToMavenLocal
        //
        // Once dyplink-android-sdk is published to Maven Central this
        // mavenLocal() entry can be removed.
        mavenLocal()
    }
}

plugins {
    id("com.android.library")
    id("kotlin-android")
}

android {
    namespace = "com.dyplink.dyplink"

    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
        getByName("test") {
            java.srcDirs("src/test/kotlin")
        }
    }

    defaultConfig {
        minSdk = 24
    }

    testOptions {
        unitTests {
            isIncludeAndroidResources = true
            all {
                it.useJUnitPlatform()
                it.outputs.upToDateWhen { false }
                it.testLogging {
                    events("passed", "skipped", "failed", "standardOut", "standardError")
                    showStandardStreams = true
                }
            }
        }
    }
}

dependencies {
    // ── Native Dyplink SDK (pulled from mavenLocal during dev) ──────────────
    // See the `mavenLocal()` note above for publishing instructions.
    val dyplinkSdkVersion = "0.1.0"
    api("com.dyplink:dyplink-core:$dyplinkSdkVersion")
    api("com.dyplink:dyplink-push:$dyplinkSdkVersion")
    api("com.dyplink:dyplink-banners:$dyplinkSdkVersion")
    api("com.dyplink:dyplink-messages:$dyplinkSdkVersion")

    // ── Coroutines (needed to bridge suspend SDK methods into Pigeon callbacks)
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1")

    // ── Test ────────────────────────────────────────────────────────────────
    testImplementation("org.jetbrains.kotlin:kotlin-test")
    testImplementation("org.mockito:mockito-core:5.0.0")
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.8.1")
}
