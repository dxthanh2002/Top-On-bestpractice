allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://jfrog.anythinktech.com/artifactory/overseas_sdk")
        }
        maven {
            url = uri("https://jfrog.anythinktech.com/artifactory/debugger")
        }
    }
}

rootProject.buildDir = file("../build")
subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
