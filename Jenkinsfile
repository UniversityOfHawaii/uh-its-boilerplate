@Library('jenkins-tools') _

pipeline {
  agent any

  environment {
    REGISTRY = releaseDataFromGit.registryFromGitStatus()
    BUILD_VERSION = releaseDataFromGit.versionFromGitStatus()

    PORTS_CONFIG = "80"
    PROXY_NETWORK_IS_EXTERNAL = true
  }
  
  stages {
    stage('Build the image') {
      steps {
        sh "REGISTRY=${REGISTRY} BUILD_VERSION=${BUILD_VERSION} make build-image"
      }
    }
    stage('Publish the image') {
      steps {
        sh "REGISTRY=${REGISTRY} BUILD_VERSION=${BUILD_VERSION} make publish-image"
      }
    }
  }
}
