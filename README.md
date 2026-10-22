# Calculator (Lab 3 + Lab 4 + Lab 5 + Lab 6)

[![CI Calculator](https://github.com/1zhouhaoran1/calculator/actions/workflows/ci-calculator.yml/badge.svg)](https://github.com/1zhouhaoran1/calculator/actions/workflows/ci-calculator.yml)

Command line calculator built with Maven, covered by a JUnit 5 test suite,
verified by a GitHub Actions CI pipeline and packaged as a Docker image.

## Build and test locally

```bash
mvn clean compile     # compile all Java sources
mvn test              # run all JUnit 5 test cases
mvn clean package -DskipTests   # build the runnable jar
```

## Run with Docker (Lab 6)

```bash
docker build -t calculator:v1 .        # multi-stage build
docker run --rm calculator:v1 3 + 5    # Result: 8.0
docker run --rm calculator:v1 10 / 0   # Error: division by zero
```

Docker Hub image: `docker.io/<your_dockerhub_name>/calculator:lab6`

## Continuous Integration

Every push to `main` and every pull request targeting `main` triggers the
workflow defined in `.github/workflows/ci-calculator.yml`:

| Step | Command |
| --- | --- |
| Checkout | `actions/checkout@v4` |
| JDK setup | `actions/setup-java@v4` (JDK 17 + 21 matrix) |
| Dependency cache | `actions/cache@v4` on `~/.m2/repository` |
| Compile | `mvn clean compile` |
| Unit tests | `mvn test` |
| Docker build (Lab 6) | `docker/build-push-action@v6` after tests pass |
| Container smoke test | `docker run calculator:v1 6 + 7` must print 13 |

The badge above always reflects the result of the latest CI run.

## Project layout

```
src/main/java/calculator/Calculator.java   # arithmetic core (bugs fixed in Lab 4)
src/main/java/calculator/Main.java         # command line entry point
src/test/java/calculator/CalculatorTest.java
src/test/java/calculator/MainTest.java
config/checkstyle.xml                      # static analysis rules
Dockerfile                                 # multi-stage image build (Lab 6)
.github/workflows/ci-calculator.yml        # CI pipeline (Lab 5 + Lab 6)
```
