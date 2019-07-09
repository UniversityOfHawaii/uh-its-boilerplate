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
        sh "TARGET_ENV=${TARGET_ENV} REGISTRY=${REGISTRY} BUILD_VERSION=${BUILD_VERSION} make build-image"
      }
    }
    stage('Publish the image') {
      steps {
        sh "TARGET_ENV=${TARGET_ENV} REGISTRY=${REGISTRY} BUILD_VERSION=${BUILD_VERSION} make publish-image"
      }
    }

    stage('Undeploy the existing stack, if any') {
      steps {
        sh "TARGET_ENV=${TARGET_ENV} REGISTRY=${REGISTRY} BUILD_VERSION=${BUILD_VERSION} make undeploy"
      }
    }
    stage('Deploy the current stack') {
      steps {
        sh "TARGET_ENV=${TARGET_ENV} REGISTRY=${REGISTRY} BUILD_VERSION=${BUILD_VERSION} make deploy"
        sh "TARGET_ENV=${TARGET_ENV} REGISTRY=${REGISTRY} BUILD_VERSION=${BUILD_VERSION} make add-traefik-labels"
      }
    }
  }
}
