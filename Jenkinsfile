@Library('jenkins-tools') _

pipeline {
  agent any

  environment {
    TARGET_ENV = "test"
    REGISTRY = releaseDataFromGit.registryFromGitStatus()
    BUILD_VERSION = releaseDataFromGit.versionFromGitStatus()
  }

  stages {
    stage('Build the image') {
      steps {
        sh "make build-image"
      }
    }
    stage('Publish the image') {
      steps {
        sh "make publish-image"
      }
    }

    stage('Undeploy the existing stack, if any') {
      steps {
        sh "make undeploy"
      }
    }
    stage('Deploy the current stack') {
      steps {
        sh "make deploy"
        sh "make add-traefik-labels"
      }
    }
  }
}
