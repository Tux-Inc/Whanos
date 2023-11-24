import java.io.File

println "Creating Jenkins jobs..."

def cloneRepo() {
    def workspace = new File('/tmp/whanos_repo')
    def cloneCommand = "git clone https://github.com/Tux-Inc/Whanos.git /tmp/whanos_repo"
    def process = cloneCommand.execute()
    process.waitFor()
    if (process.exitValue() != 0) {
        println "Error cloning repository: " + process.err.text
        return null
    }
    return new File(workspace, "images")
}

def imagesDir = cloneRepo()
println "Images directory: " + imagesDir

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
            text("""
                freeStyleJob("Projects/$DISPLAY_NAME") {
                    agent {
                        kubernetes {
                            yaml '''
                                apiVersion: v1
                                kind: Pod
                                spec:
                                containers:
                                    - name: docker
                                    image: docker
                                    command:
                                        - cat
                                    tty: true
                                    volumeMounts:
                                        - mountPath: /var/run/docker.sock
                                        name: docker-sock
                                        - mountPath: /whanos
                                        name: whanos
                                volumes:
                                    - name: docker-sock
                                    hostPath:
                                        path: /var/run/docker.sock
                                    - name: whanos
                                    hostPath:
                                        path: /whanos
                            '''
                        }
                    }
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
                        shell('''
                            while true; do
                                echo "Pulling latest version of the image..."
                                sleep 60
                            done
                        ''')
                    }
                }
            """.stripIndent())
        }
    }
}
