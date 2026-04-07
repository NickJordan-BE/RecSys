
# Stage 1: Build
FROM maven:3.9-eclipse-temurin-21 AS base

WORKDIR /app

COPY pom.xml .

RUN mvn dependency:go-offline 

FROM base AS style-check

COPY src ./src

RUN mvn spotless:check && mvn checkstyle:checkstyle

FROM base AS build 

COPY src ./src

RUN mvn package -DskipTests

# Stage 2: Run
FROM eclipse-temurin:21-jre-alpine 

WORKDIR /app

COPY --from=style-check /etc/passwd /dev/null   

COPY --from=build /app/target/*.jar app.jar

CMD ["java", "-jar", "app.jar"]

ENTRYPOINT [ "java", "-jar", "app.jar" ]