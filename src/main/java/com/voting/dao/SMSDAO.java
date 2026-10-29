package com.voting.dao;

import com.voting.model.SMSLog;
import com.voting.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SMSDAO {

    public boolean logSMS(int electionId, int voterId, String message, String status) {
        String sql = "INSERT INTO sms_logs (election_id, voter_id, message, status) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, electionId);
            stmt.setInt(2, voterId);
            stmt.setString(3, message);
            stmt.setString(4, status);

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<SMSLog> getSMSLogsByElection(int electionId) {
        List<SMSLog> logs = new ArrayList<>();
        String sql = "SELECT * FROM sms_logs WHERE election_id = ? ORDER BY sent_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, electionId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                SMSLog log = new SMSLog();
                log.setId(rs.getInt("id"));
                log.setElectionId(rs.getInt("election_id"));
                log.setVoterId(rs.getInt("voter_id"));
                log.setMessage(rs.getString("message"));
                log.setStatus(rs.getString("status"));
                log.setSentAt(rs.getTimestamp("sent_at"));
                logs.add(log);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return logs;
    }

    public List<SMSLog> getSMSLogsByVoter(int voterId) {
        List<SMSLog> logs = new ArrayList<>();
        String sql = "SELECT s.*, e.title as election_title FROM sms_logs s " +
                     "JOIN elections e ON s.election_id = e.id " +
                     "WHERE s.voter_id = ? ORDER BY s.sent_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, voterId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                SMSLog log = new SMSLog();
                log.setId(rs.getInt("id"));
                log.setElectionId(rs.getInt("election_id"));
                log.setVoterId(rs.getInt("voter_id"));
                log.setMessage(rs.getString("message"));
                log.setStatus(rs.getString("status"));
                log.setSentAt(rs.getTimestamp("sent_at"));
                log.setElectionTitle(rs.getString("election_title"));
                logs.add(log);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return logs;
    }
}
