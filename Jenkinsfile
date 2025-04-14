pipeline {
    agent any

    tools {
        jdk 'OpenJDK 17'
    }

    stages {
        stage('Clone') {
            steps {
                git credentialsId: 'github-creds', url: 'https://github.com/z-z-one/Email.git'
            }
        }

        stage('Build') {
            steps {
                sh './gradlew clean build'
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    withCredentials([
                        string(credentialsId: 'DOCKERHUB_ID', variable: 'DOCKERHUB_ID'),
                        usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')
                    ]) {
                        def imageName = "${DOCKERHUB_ID}/email:${env.BUILD_NUMBER}"
                        sh "docker build -t ${imageName} ."
                        sh "echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin"
                        sh "docker push ${imageName}"
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    withCredentials([
                        sshUserPrivateKey(credentialsId: 'SSH_KEY_PATH', keyFileVariable: 'SSH_KEY'),
                        string(credentialsId: 'DOCKERHUB_ID', variable: 'DOCKERHUB_ID'),
                        string(credentialsId: 'ec2_ip', variable: 'EC2_IP')
                    ]) {
                        sh """
                        ssh -i ${SSH_KEY} ubuntu@${EC2_IP} '
                          docker pull ${DOCKERHUB_ID}/email:${env.BUILD_NUMBER} &&
                          docker stop spring-container || true &&
                          docker rm spring-container || true &&
                          docker run -d --name spring-container -p 8080:8080 ${DOCKERHUB_ID}/email:${env.BUILD_NUMBER}
                        '
                        """
                    }
                }
            }
        }

    }

    post {
        success {
            echo '배포 성공!'
        }
        failure {
            echo '빌드 또는 배포 실패!'
        }
    }
}
