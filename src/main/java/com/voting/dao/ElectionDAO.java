package com.voting.dao;

import com.voting.model.Election;
import com.voting.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ElectionDAO {

    public boolean addElection(Election election) {
        String sql = "INSERT INTO elections (title, description, start_time, end_time, status) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, election.getTitle());
            stmt.setString(2, election.getDescription());
            stmt.setTimestamp(3, election.getStartTime());
            stmt.setTimestamp(4, election.getEndTime());
            stmt.setString(5, election.getStatus() != null ? election.getStatus() : "DRAFT");

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Election> getAllElections() {
        List<Election> elections = new ArrayList<>();
        String sql = "SELECT e.*, c.name as winner_name FROM elections e LEFT JOIN candidates c ON e.winner_id = c.id ORDER BY e.start_time DESC";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                elections.add(extractElectionFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return elections;
    }

    public Election getElectionById(int id) {
        String sql = "SELECT e.*, c.name as winner_name FROM elections e LEFT JOIN candidates c ON e.winner_id = c.id WHERE e.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return extractElectionFromResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateElection(Election election) {
        String sql = "UPDATE elections SET title = ?, description = ?, start_time = ?, end_time = ?, status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, election.getTitle());
            stmt.setString(2, election.getDescription());
            stmt.setTimestamp(3, election.getStartTime());
            stmt.setTimestamp(4, election.getEndTime());
            stmt.setString(5, election.getStatus());
            stmt.setInt(6, election.getId());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    public boolean updateElectionStatus(int id, String status) {
        String sql = "UPDATE elections SET status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, status);
            stmt.setInt(2, id);

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean declareWinner(int id, int winnerId) {
        String sql = "UPDATE elections SET winner_id = ?, status = 'DECLARED' WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, winnerId);
            stmt.setInt(2, id);

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteElection(int id) {
        String sql = "DELETE FROM elections WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private Election extractElectionFromResultSet(ResultSet rs) throws SQLException {
        Election election = new Election();
        election.setId(rs.getInt("id"));
        election.setTitle(rs.getString("title"));
        election.setDescription(rs.getString("description"));
        election.setStartTime(rs.getTimestamp("start_time"));
        election.setEndTime(rs.getTimestamp("end_time"));
        election.setStatus(rs.getString("status"));
        election.setCreatedAt(rs.getTimestamp("created_at"));
        
        int winnerId = rs.getInt("winner_id");
        if (!rs.wasNull()) {
            election.setWinnerId(winnerId);
            if (winnerId == -1) {
                election.setWinnerName("TIE (No Single Winner)");
            } else {
                election.setWinnerName(rs.getString("winner_name"));
            }
        }
        
        election.setPrivate(rs.getBoolean("is_private"));
        
        return election;
    }

    public boolean updateElectionPrivacy(int id, boolean isPrivate) {
        String sql = "UPDATE elections SET is_private = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setBoolean(1, isPrivate);
            stmt.setInt(2, id);

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean isVoterEligible(int electionId, int voterId) {
        // First check if the election is private
        String checkSql = "SELECT is_private FROM elections WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(checkSql)) {
            stmt.setInt(1, electionId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next() && !rs.getBoolean("is_private")) {
                return true; // It is a PUBLIC election
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // If it is configured, check if this specific voter is in it
        String sql = "SELECT 1 FROM election_voters WHERE election_id = ? AND voter_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, electionId);
            stmt.setInt(2, voterId);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Integer> getEligibleVoterIds(int electionId) {
        List<Integer> voterIds = new ArrayList<>();
        String sql = "SELECT voter_id FROM election_voters WHERE election_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, electionId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                voterIds.add(rs.getInt("voter_id"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return voterIds;
    }

    public boolean updateElectionVoters(int electionId, List<Integer> voterIds) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            
            // Delete existing
            try (PreparedStatement deleteStmt = conn.prepareStatement("DELETE FROM election_voters WHERE election_id = ?")) {
                deleteStmt.setInt(1, electionId);
                deleteStmt.executeUpdate();
            }
            
            // Insert new
            if (voterIds != null && !voterIds.isEmpty()) {
                try (PreparedStatement insertStmt = conn.prepareStatement("INSERT INTO election_voters (election_id, voter_id) VALUES (?, ?)")) {
                    for (int voterId : voterIds) {
                        insertStmt.setInt(1, electionId);
                        insertStmt.setInt(2, voterId);
                        insertStmt.addBatch();
                    }
                    insertStmt.executeBatch();
                }
            }
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try { 
                    conn.setAutoCommit(true);
                    conn.close(); 
                } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        return false;
    }

    public List<Election> getElectionsForVoter(int voterId) {
        List<Election> elections = new ArrayList<>();
        String sql = "SELECT e.*, c.name as winner_name FROM elections e " +
                     "LEFT JOIN candidates c ON e.winner_id = c.id " +
                     "WHERE e.is_private = FALSE OR e.id IN (SELECT election_id FROM election_voters WHERE voter_id = ?) " +
                     "ORDER BY e.start_time DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, voterId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                elections.add(extractElectionFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return elections;
    }
}
