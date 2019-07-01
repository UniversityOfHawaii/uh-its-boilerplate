@Library('jenkins-tools') _

pipeline {
  agent any

  environment {
    REGISTRY = releaseDataFromGit.registryFromGitStatus()
    BUILD_VERSION = releaseDataFromGit.versionFromGitStatus()
  }
  
  stages {
    stage('Build the image') {
      steps {
        sh "BUILD_VERSION=${BUILD_VERSION} REGISTRY=${REGISTRY} make build-image"
      }
    }
    stage('Publish the image') {
      steps {
        sh "BUILD_VERSION=${BUILD_VERSION} REGISTRY=${REGISTRY} make publish-image"
      }
    }
  }
}
