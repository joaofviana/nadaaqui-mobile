allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Plugins Flutter (app_settings, geolocator, …) ainda declaram compileSdk 33.
// AGP 9 recusa dependências AndroidX que exigem 34+.
fun org.gradle.api.Project.forceCompileSdk36() {
    pluginManager.withPlugin("com.android.library") {
        extensions.findByName("android")?.let { ext ->
            try {
                ext.javaClass.methods.firstOrNull { it.name == "setCompileSdk" && it.parameterCount == 1 }
                    ?.invoke(ext, 36)
            } catch (_: Exception) {
            }
            try {
                ext.javaClass.methods.firstOrNull { it.name == "setCompileSdkVersion" && it.parameterCount == 1 }
                    ?.invoke(ext, 36)
            } catch (_: Exception) {
            }
        }
    }
}

subprojects {
    forceCompileSdk36()
    afterEvaluate { forceCompileSdk36() }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
