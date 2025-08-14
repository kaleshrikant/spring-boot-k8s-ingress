FROM openjdk:21-slim

EXPOSE 8081

ADD build/libs/blog-service.jar blog-service.jar

ENTRYPOINT ["java", "-jar", "blog-service.jar"]