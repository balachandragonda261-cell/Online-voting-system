package com.voting.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    // Use environment variable DB_PATH if set (for cloud), otherwise /tmp for Docker,
    // or ./voting_db for local development.
    private static final String DB_PATH = System.getenv("DB_PATH") != null
            ? System.getenv("DB_PATH")
            : (System.getProperty("os.name").toLowerCase().contains("win") ? "./voting_db" : "/tmp/voting_db");
    private static final String URL = "jdbc:h2:" + DB_PATH + ";MODE=MySQL;DATABASE_TO_LOWER=TRUE";
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
