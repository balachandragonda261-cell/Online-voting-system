# =========================================================
# Stage 1: Build the WAR file using Maven
# =========================================================
FROM maven:3.9.6-eclipse-temurin-11 AS build
WORKDIR /app

# Copy pom.xml first to cache Maven dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy full source and build WAR (skip tests for faster build)
COPY src ./src
RUN mvn clean package -DskipTests -B

# =========================================================
# Stage 2: Run on Tomcat 9 (JRE 11)
# =========================================================
FROM tomcat:9.0-jre11

# Remove default Tomcat sample apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy built WAR to ROOT so it serves at http://host:8080/
COPY --from=build /app/target/OnlineVotingSystem.war /usr/local/tomcat/webapps/ROOT.war

# H2 database stored in /data (can be mounted as a persistent volume on Railway)
RUN mkdir -p /data

# Tell the app where to store the H2 database file
ENV DB_PATH=/data/voting_db

# Expose port 8080
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
