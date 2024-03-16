# Stage 1: Build Fineract JAR
FROM azul/zulu-openjdk-debian:11 AS builder

RUN apt-get update -qq && apt-get install -y wget

COPY . fineract

WORKDIR /fineract

RUN ./gradlew --no-daemon -q -x rat -x compileTestJava -x test -x spotlessJavaCheck -x spotlessJava bootJar

# Stage 2: Run Fineract
FROM openjdk:alpine

COPY --from=builder /fineract/target/BOOT-INF/lib /app/lib
COPY --from=builder /fineract/target/META-INF /app/META-INF
COPY --from=builder /fineract/target/fineract-provider.jar /app.jar

WORKDIR /

EXPOSE 8080

CMD ["java", "-jar", "/app.jar"]
