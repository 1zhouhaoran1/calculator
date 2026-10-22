# ============================================================
# Lab 6 - Multi-stage Dockerfile for the Calculator project
# Stage 1 (build): full Maven + JDK image, compiles the jar
# Stage 2 (run)  : lightweight JRE image, only runs the jar
# ============================================================

# --- Stage 1: build -----------------------------------------
# FROM: choose the base image. maven:3.9-eclipse-temurin-17
# already contains Maven 3.9 and JDK 17, so we can run mvn directly.
FROM maven:3.9-eclipse-temurin-17 AS build

# WORKDIR: set the working directory inside the container.
# Every later COPY/RUN is executed relative to this folder.
WORKDIR /app

# COPY: copy only pom.xml first so that the dependency layer can be cached.
COPY pom.xml .

# RUN: execute a shell command at build time.
# Download all dependencies into the image layer; this layer is reused
# as long as pom.xml does not change, which speeds up repeated builds.
RUN mvn -B dependency:go-offline

# COPY: copy the Java source code into the container.
COPY src ./src

# RUN: compile and package the project into target/calculator-1.0.0.jar.
# -DskipTests: unit tests were already executed by the CI pipeline,
# so they do not need to run again inside the Docker build.
RUN mvn -B clean package -DskipTests

# --- Stage 2: runtime ---------------------------------------
# FROM: start a second, much smaller image that only contains a JRE.
# No Maven and no source code are shipped to production.
FROM eclipse-temurin:17-jre-jammy

# WORKDIR: working directory of the final image.
WORKDIR /app

# COPY --from=build: copy the packaged jar FROM the first stage
# INTO the runtime stage. This is the core instruction of a
# multi-stage build.
COPY --from=build /app/target/calculator-1.0.0.jar calculator.jar

# ENTRYPOINT: fixed command that always runs when the container starts.
# Arguments given to "docker run ... <args>" are appended to this command,
# e.g. docker run calculator:v1 3 + 5 -> java -jar calculator.jar 3 + 5
ENTRYPOINT ["java", "-jar", "calculator.jar"]

# CMD: default arguments used when the user does not provide any.
# With no arguments the calculator prints its usage message.
CMD []
