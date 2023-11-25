import java.io.File

def workspace = new File('/tmp/whanos_repo')
def imagesDir = new File(workspace, "images")

def languages = []

if (imagesDir.exists() && imagesDir.isDirectory()) {
    def directories = imagesDir.listFiles().findAll { it.isDirectory() }
    languages = directories.collect { it.name }
    println "Available languages: " + languages
} else {
    println "Images directory not found or is not a directory, no languages available"
}

folder("Whanos base images") {
    description("Whanos base images folder")
}

folder("Projects") {
    description("Projects folder")
}

languages.each { language ->
    println "Creating job for language: " + language
    freeStyleJob("Whanos base images/whanos-$language") {
        steps {
            shell("docker build $imagesDir/$language -t whanos-$language -f $imagesDir/$language/Dockerfile.base")
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
                        git {
                            remote {
                                github("$GITHUB_NAME", "ssh")
                                credentials('jenkins-ssh-key')
                            }
                        }
                    }
                    triggers {
                        scm('* * * * *')
                    }
                    wrappers {
                        preBuildCleanup()
                    }
                    steps {
                        shell(\'\'\'
                            chmod -R 777 /whanos
                            sh -c "/whanos/scripts/whanos.sh"
                        \'\'\')
                    }
                }
            ''')
        }
    }
}
