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
