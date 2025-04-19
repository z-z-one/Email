FROM openjdk:17-jdk
ARG JAR_FILE=/build/libs/*.jar

COPY ${JAR_FILE} email.jar
ENTRYPOINT ["java","-jar","/email.jar"]

#RUN ln -snf /usr/share/zoneinfo/Asia/Seoul /etc/localtime