pipeline {
    agent any // controller already has docker CLI wired to dind

    options {
        timeout(time: 15, unit: 'MINUTES') // catches hangs (network, slow pulls) instead of running forever
        buildDiscarder(logRotator(numToKeepStr: '10')) // keep last 10 builds' logs/artifacts, discard older
    }

    environment {
        IMAGE_NAME = 'ivanbezcurtin/aws-express-sample'
        IMAGE_TAG  = "${BUILD_NUMBER}"
        TRIVY_BIN  = "${WORKSPACE}/trivy-bin"
    }

    stages {
        stage('Install & Test') {
            agent {
                docker { image 'node:16' } // Node 16 build agent
            }
            steps {
                sh 'npm ci'
                sh 'npm test'
            }
        }

        stage('Build Image') {
            steps {
                sh 'docker build -t "$IMAGE_NAME:$IMAGE_TAG" .'
            }
        }

        stage('Install Trivy') {
            steps {
                sh '''
                    set -e
                    mkdir -p "$TRIVY_BIN"
                    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b "$TRIVY_BIN"
                '''
            }
        }

        stage('Security Scan Report') {
            steps {
                // full report, medium and up - saved to a file so it can be archived
                sh '"$TRIVY_BIN"/trivy image --severity MEDIUM,HIGH,CRITICAL "$IMAGE_NAME:$IMAGE_TAG" | tee trivy-report.txt'
                archiveArtifacts artifacts: 'trivy-report.txt'
            }
        }

        stage('Security Gate') {
            steps {
                // fails the build only on High/Critical
                sh '"$TRIVY_BIN"/trivy image --exit-code 1 --severity HIGH,CRITICAL "$IMAGE_NAME:$IMAGE_TAG"'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
                    sh 'docker push "$IMAGE_NAME:$IMAGE_TAG"'
                }
                sh 'docker rmi "$IMAGE_NAME:$IMAGE_TAG" || true' // Clear images after
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
        }
    }
}
