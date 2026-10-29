package com.voting.service;

import com.voting.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class FraudDetectionService {

    private static final int MAX_FAILED_ATTEMPTS = 5;
    private static final int TIME_WINDOW_MINUTES = 15;

    /**
     * Checks if a given IP address has exhibited suspicious behavior
     * based on recent audit logs. Returns true if suspicious.
     */
    public boolean isSuspiciousIp(String ipAddress) {
        // Query to check for excessive failed actions or anomalous behavior from the same IP in the last 15 mins
        String sql = "SELECT COUNT(*) FROM audit_logs WHERE ip_address = ? " +
                     "AND action LIKE '%FAIL%' " +
                     "AND timestamp > DATEADD('MINUTE', -?, CURRENT_TIMESTAMP)";
                     
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, ipAddress);
            stmt.setInt(2, TIME_WINDOW_MINUTES);
            
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                int recentFailures = rs.getInt(1);
                return recentFailures >= MAX_FAILED_ATTEMPTS;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
