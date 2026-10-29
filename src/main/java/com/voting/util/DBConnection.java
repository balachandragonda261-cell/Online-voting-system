package com.voting.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    // Use /tmp for writable storage in Docker/cloud containers.
    // AUTO_SERVER=TRUE removed — it tries to bind a TCP port which fails on Render/cloud.
    // INIT removed — schema is loaded via DatabaseInitializer from classpath.
    private static final String URL = "jdbc:h2:/tmp/voting_db;MODE=MySQL;DATABASE_TO_LOWER=TRUE";
    private static final String USER = "sa";
    private static final String PASSWORD = "";

    static {
        try {
            Class.forName("org.h2.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
