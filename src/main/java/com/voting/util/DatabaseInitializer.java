package com.voting.util;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.Scanner;

@WebListener
public class DatabaseInitializer implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("Initializing Database with H2...");
        try (Connection conn = DBConnection.getConnection()) {

            // Step 1: Run schema.sql to create tables
            runSchemaSql(conn);

            // Step 2: Seed default users using Java (avoids SQL parser issues)
            seedDefaultUsers(conn);

            System.out.println("Database Initialization Complete.");

        } catch (Exception e) {
            System.err.println("Database initialization error: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private void runSchemaSql(Connection conn) {
        InputStream is = getClass().getClassLoader().getResourceAsStream("sql/schema.sql");
        if (is == null) {
            System.err.println("Could not find sql/schema.sql file.");
            return;
        }
        try (Statement stmt = conn.createStatement();
             Scanner scanner = new Scanner(is, StandardCharsets.UTF_8.name())) {

            scanner.useDelimiter(";");
            while (scanner.hasNext()) {
                String sql = scanner.next().trim();
                // Skip empty lines and pure comment blocks
                if (sql.isEmpty()) continue;
                // Remove leading comment lines to get to the actual SQL
                StringBuilder cleaned = new StringBuilder();
                for (String line : sql.split("\n")) {
                    String trimmedLine = line.trim();
                    if (!trimmedLine.startsWith("--")) {
                        cleaned.append(line).append("\n");
                    }
                }
                String cleanSql = cleaned.toString().trim();
                if (!cleanSql.isEmpty()) {
                    try {
                        stmt.execute(cleanSql);
                    } catch (Exception ex) {
                        System.out.println("Ignored SQL (already exists): " + ex.getMessage());
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Error running schema.sql: " + e.getMessage());
        }
    }

    private void seedDefaultUsers(Connection conn) {
        try {
            // Always delete and re-insert default accounts to ensure correct passwords
            String deleteSql = "DELETE FROM users WHERE email IN (?, ?, ?)";
            try (PreparedStatement del = conn.prepareStatement(deleteSql)) {
                del.setString(1, "admin@voting.com");
                del.setString(2, "alice@voting.com");
                del.setString(3, "bob@voting.com");
                del.executeUpdate();
            }

            String insertSql = "INSERT INTO users (name, email, password_hash, role, status) VALUES (?, ?, ?, ?, ?)";

            // Hash passwords at runtime using BCrypt — guaranteed to work
            String adminHash = PasswordUtil.hashPassword("admin123");
            String voterHash = PasswordUtil.hashPassword("voter123");

            // Insert Admin
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setString(1, "System Admin");
                ps.setString(2, "admin@voting.com");
                ps.setString(3, adminHash);
                ps.setString(4, "ADMIN");
                ps.setString(5, "APPROVED");
                ps.executeUpdate();
            }

            // Insert Voter Alice
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setString(1, "Voter Alice");
                ps.setString(2, "alice@voting.com");
                ps.setString(3, voterHash);
                ps.setString(4, "VOTER");
                ps.setString(5, "APPROVED");
                ps.executeUpdate();
            }

            // Insert Voter Bob
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setString(1, "Voter Bob");
                ps.setString(2, "bob@voting.com");
                ps.setString(3, voterHash);
                ps.setString(4, "VOTER");
                ps.setString(5, "APPROVED");
                ps.executeUpdate();
            }

            System.out.println("Default users seeded successfully.");
            System.out.println("  Admin: admin@voting.com / admin123");
            System.out.println("  Voter: alice@voting.com / voter123");
            System.out.println("  Voter: bob@voting.com  / voter123");

        } catch (Exception e) {
            System.err.println("Error seeding default users: " + e.getMessage());
            e.printStackTrace();
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("Application Context Destroyed.");
    }
}
