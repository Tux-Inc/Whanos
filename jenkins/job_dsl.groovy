import java.io.File

def imagesDir = new File('/images')
def languages = []

if (imagesDir.exists() && imagesDir.isDirectory()) {
    File[] files = imagesDir.listFiles()
    def directories = files.findAll { it.isDirectory() }
    languages = directories.collect { it.name.capitalize() }
    println "Available languages: " + languages
} else {
    println "Images directory not found or is not a directory, no languages available"
}

folder("Whanos base images") {
    description("Whanos base images folder")
}

folder("Projets") {
    description("Projets folder")
}

languages.each { language ->
    freeStyleJob("Whanos base images/whanos-$language") {
        steps {
            shell("docker build /images/$language -t whanos-$language -f /images/$language/Dockerfile.base")
        }
    }
}

freeStyleJob("Whanos base images/Build all base images") {
    publishers {
        downstreamParameterized {
            trigger("Whanos base images/whanos-$language", false)
            condition("SUCCESS")
            parameters {
                predefinedProp("language", languages.join(','))
            }
        }
    }
}

freeStyleJob("link-project") {
    parameters {
        stringParam("GITHUB_NAME", null, "GitHub repository owner/repo_name (e.g.: 'EpitechIT31000/chocolatine')")
        stringParam("DISPLAY_NAME", null, "Display name for the job")
    }
    steps {
        dsl {
            text('''
                freeStyleJob("Projects/$DISPLAY_NAME") {
                    wrappers {
                        preBuildCleanup()
                    }
                    scm {
                        github("$GITHUB_NAME")
                    }
                    triggers {
                        scm("* * * * *")
                    }
                    steps {
                        shell("echo 'TODO: BUILD IMAGE'")
                    }
                }

            ''')
        }
    }
}
