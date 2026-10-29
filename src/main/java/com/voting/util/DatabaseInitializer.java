package com.voting.util;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.Statement;
import java.util.Scanner;

@WebListener
public class DatabaseInitializer implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("Initializing Database with H2...");
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {

            InputStream is = getClass().getClassLoader().getResourceAsStream("sql/schema.sql");
            if (is != null) {
                try (Scanner scanner = new Scanner(is, StandardCharsets.UTF_8.name())) {
                    scanner.useDelimiter(";");
                    while (scanner.hasNext()) {
                        String sql = scanner.next().trim();
                        if (!sql.isEmpty() && !sql.startsWith("--")) {
                            try {
                                stmt.execute(sql);
                            } catch (Exception ex) {
                                System.out.println("Ignored SQL error (e.g. duplicate key): " + ex.getMessage());
                            }
                        }
                    }
                }
                System.out.println("Database Initialization Complete.");
            } else {
                System.err.println("Could not find sql/schema.sql file.");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("Application Context Destroyed.");
    }
}
