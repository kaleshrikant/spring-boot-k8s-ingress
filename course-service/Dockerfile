FROM openjdk:21-slim

EXPOSE 8082

ADD build/libs/course-service.jar course-service.jar

ENTRYPOINT ["java", "-jar", "course-service.jar"]