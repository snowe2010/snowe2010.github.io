---
layout: post
title: "spek2 gradle kotlin dsl setup"
description: "setting up spek2 with the kotlin-dsl for gradle"
date: 2019-02-03
tags: [tutorial, kotlin, gradle, kotlin dsl]
comments: true
---

So far getting spek2 setup with kotlin and a kotlin-dsl build.gradle.kts has been a massive pain in the butt. 

Here are the things you need:

---

spek2 is not located in jcenter or maven central. Therefore you need to specify the repository. Do this in your
`init.gradle.kts` or `build.gradle.kts`

```kotlin
repositories {
  maven(url = "https://dl.bintray.com/spekframework/spek-dev/")
}
```

---

spek2 requires quite a lot of different dependencies.

```kotlin
val spekVersion = "2.0.0-alpha.2"

dependencies {
  testImplementation("org.spekframework.spek2:spek-dsl-jvm:$spekVersion") {
      exclude(group = "org.jetbrains.kotlin")
  }
  testRuntimeOnly("org.spekframework.spek2:spek-runner-junit5:$spekVersion") {
      exclude(group = "org.junit.platform")
      exclude(group = "org.jetbrains.kotlin")
  }
  testImplementation(group = "org.junit.platform", name = "junit-platform-engine", version = "1.3.0-RC1")
}
```

The junit platform dependency is necessary to run the tests outside of IntelliJ. If you don't provide it, 
tests will succeed in IntelliJ but fail on the command line!

---

You must configure the `Test` task

```kotiln
tasks {
  withType<Test> {
    useJUnitPlatform {
      includeEngines("spek2")
    }
  }
}
```

That's it. you can take a look at a full working application using spek2 [here](https://github.com/snowe2010/pretty-print)

