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

# Render & Railway use /data as persistent disk mount point
RUN mkdir -p /data

# Set DB path — overridden by render.yaml/railway.json env var at runtime
ENV DB_PATH=/data/voting_db

# Render injects PORT env variable; configure Tomcat to use it via setenv.sh
RUN echo 'export JAVA_OPTS="$JAVA_OPTS -Dport.http.nonssl=${PORT:-8080}"' >> /usr/local/tomcat/bin/setenv.sh && \
    sed -i 's/port="8080"/port="${port.http.nonssl:-8080}"/' /usr/local/tomcat/conf/server.xml

# Expose 8080 (Render maps its external port to this)
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
