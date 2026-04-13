
# Stage 1: Build
FROM maven:3.9-eclipse-temurin-21 AS base

WORKDIR /app

COPY services/filtering/pom.xml .

RUN mvn dependency:go-offline 

FROM base AS style-check

COPY services/filtering/src ./src

RUN mvn spotless:check && mvn checkstyle:checkstyle

FROM base AS build 

COPY api/proto ./api/proto

COPY services/filtering/src ./src

RUN mvn package -DskipTests

RUN mkdir extracted && \
    java -Djarmode=tools -jar target/*.jar extract --layers --launcher --destination extracted

FROM eclipse-temurin:21-jre-alpine 

WORKDIR /app

COPY --from=style-check /etc/passwd /dev/null   

COPY --from=build /app/extracted/dependencies/ ./
COPY --from=build /app/extracted/spring-boot-loader/ ./
COPY --from=build /app/extracted/snapshot-dependencies/ ./
COPY --from=build /app/extracted/application/ ./

CMD ["java", "-jar", "app.jar"]

ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]