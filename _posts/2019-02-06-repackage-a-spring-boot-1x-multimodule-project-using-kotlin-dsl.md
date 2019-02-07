---
layout: post
title: "repackage a spring boot 1.x multimodule project using kotlin dsl"
description: "Fixing a repackage issue with a multi-module Spring Boot 1.x kotlin-dsl gradle project"
date: 2019-02-06
tags: [spring, spring 1.x, gradle, kotlin-dsl]
comments: true
---

Small post today. We use a large multimodule Spring Boot 1.x project at work.
I've been transitioning this to Gradle over the past few months. Initially I had
created the `build.gradle.kts` using `compile` and `testCompile` configurations,
but a fellow dev requested that I update to `implementation`. I had been waiting to
do this because I knew it would cause issues, but it still needed to be done.

Promptly after doing so I began receiving reports that the runnable jar was way too
small. I investigated and it appeared that only the deploy module was being included
in the runnable.

Here is a diagram of our module setup

```
root
|- module1
|- common
|- common-test
|- module2-common
|- module2-write
|- module3-common
|- module3-write
|- module4
|- module5
|- deploy
```

these all have dependencies on each other, but the main deploy module is what
we're worried about. It has these dependencies:

```
deploy/build.gradle.kts
    implementation(project(":common"))
    implementation(project(":module1"))
    implementation(project(":module2-common"))
    implementation(project(":module2-write"))
    implementation(project(":module3-common"))
    implementation(project(":module3-write"))
    implementation(project(":module4"))
    implementation(project(":module5"))
    testImplementation(project(":common-test"))
```

The main deploy module will build a runnable Spring Boot 1.x jar into the
`deploy/build/libs` folder. The deploy module will be a repackaged version of
all of the other modules.

Changing from `compile` to `implementation` actually causes the spring boot plugin
to fail to package all the other modules, due to 
[this comment](https://github.com/spring-projects/spring-boot/issues/9143#issuecomment-300226802)

As noted in that comment, the solution is to create a custom configuration for the `bootRepackage`
task.

```groovy
configurations {
    custom {
        it.extendsFrom implementation
    }
}

bootRepackage {
    customConfiguration = 'implementation'
}
```

but, with the kotlin dsl it's a bit different!
The solution is still pretty simple though. 

```kotlin
val implementation = configurations.getByName("implementation")
configurations.create("includeAllJars") {
    this.extendsFrom(implementation)
}
withType<BootJar> {
    this.setCustomConfiguration("includeAllJars")
}
```
