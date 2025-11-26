FROM eclipse-temurin:21-jdk

WORKDIR /app

COPY .mvn/ .mvn

COPY mvnw pom.xml ./

RUN ./mvnw dependency:go-offline

COPY src ./src

EXPOSE 8060

CMD ["./mvnw", "spring-boot:run"]

