# Build stage
FROM maven:3.9.6-eclipse-temurin-11 AS build
WORKDIR /app

# Copy pom.xml and download dependencies (caching step)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code and package the WAR file
COPY src ./src
RUN mvn clean package -DskipTests

# Run stage
FROM tomcat:9.0-jre11
# Remove default Tomcat apps to avoid conflicts
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the built WAR file to ROOT.war so it serves at the root path (/)
COPY --from=build /app/target/OnlineVotingSystem.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
