import java.io.File
import hudson.plugins.git.GitSCM
import hudson.plugins.git.extensions.impl.RelativeTargetDirectory
import hudson.plugins.git.extensions.impl.CloneOption

// Constants
final String REPO_URL = "https://github.com/Tux-Inc/Whanos.git"
final String IMAGES_DIR_RELATIVE_PATH = "images"
final String BASE_FOLDER_NAME = "Whanos base images"
final String PROJECTS_FOLDER_NAME = "Projects"

// Utility function to clone the repository and return the directory path
def cloneRepoAndGetImagesDir() {
    def workspace = new File('/tmp/whanos_repo')
    def scm = new GitSCM(REPO_URL)
    scm.extensions.add(new CloneOption(false, false, "", 10))
    scm.extensions.add(new RelativeTargetDirectory(workspace.getAbsolutePath()))

    // Clone the repo
    scm.checkout(null, workspace, null, null, null, null)

    // Return path to images directory
    return new File(workspace, IMAGES_DIR_RELATIVE_PATH)
}

def imagesDir = cloneRepoAndGetImagesDir()
def languages = []

if (imagesDir.exists() && imagesDir.isDirectory()) {
    def directories = imagesDir.listFiles().findAll { it.isDirectory() }
    languages = directories.collect { it.name.capitalize() }
    println "Available languages: " + languages
} else {
    println "Images directory not found or is not a directory, no languages available"
}

folder(BASE_FOLDER_NAME) {
    description("Whanos base images folder")
}

folder(PROJECTS_FOLDER_NAME) {
    description("Projects folder")
}

languages.each { language ->
    freeStyleJob("$BASE_FOLDER_NAME/whanos-$language") {
        steps {
            shell("docker build ${imagesDir.absolutePath}/$language -t whanos-$language -f ${imagesDir.absolutePath}/$language/Dockerfile.base")
        }
    }
}

freeStyleJob("$BASE_FOLDER_NAME/Build all base images") {
    publishers {
        downstreamParameterized {
            trigger("$BASE_FOLDER_NAME/whanos-$language", false)
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
