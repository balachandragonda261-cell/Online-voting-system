package com.voting.dao;

import com.voting.model.Vote;
import com.voting.util.DBConnection;

import java.sql.*;
import java.util.HashMap;
import java.util.Map;

public class VoteDAO {

    public boolean castVote(Vote vote) {
        String sql = "INSERT INTO votes (election_id, voter_id, candidate_id, previous_hash, vote_hash) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, vote.getElectionId());
            stmt.setInt(2, vote.getVoterId());
            stmt.setInt(3, vote.getCandidateId());
            stmt.setString(4, vote.getPreviousHash());
            stmt.setString(5, vote.getVoteHash());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            // This might throw if unique constraint (election_id, voter_id) is violated
            e.printStackTrace();
        }
        return false;
    }

    public String getLastVoteHash() {
        String sql = "SELECT vote_hash FROM votes ORDER BY id DESC LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
             
             ResultSet rs = stmt.executeQuery();
             if (rs.next()) {
                 return rs.getString("vote_hash");
             }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return "GENESIS";
    }

    public boolean hasVoted(int electionId, int voterId) {
        String sql = "SELECT id FROM votes WHERE election_id = ? AND voter_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, electionId);
            stmt.setInt(2, voterId);
            ResultSet rs = stmt.executeQuery();

            return rs.next(); // True if a vote exists
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public java.util.List<Integer> getVotedElectionIds(int voterId) {
        java.util.List<Integer> ids = new java.util.ArrayList<>();
        String sql = "SELECT election_id FROM votes WHERE voter_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, voterId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                ids.add(rs.getInt("election_id"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return ids;
    }

    public Map<Integer, Integer> getVoteCountByCandidate(int electionId) {
        Map<Integer, Integer> voteCounts = new HashMap<>();
        String sql = "SELECT c.id as candidate_id, (COUNT(v.id) + COALESCE(c.offline_votes, 0)) as count " +
                     "FROM candidates c " +
                     "LEFT JOIN votes v ON c.id = v.candidate_id " +
                     "WHERE c.election_id = ? " +
                     "GROUP BY c.id, c.offline_votes";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, electionId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                voteCounts.put(rs.getInt("candidate_id"), rs.getInt("count"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return voteCounts;
    }

    public int getTotalVotesByElection(int electionId) {
        String sql = "SELECT (SELECT COUNT(id) FROM votes WHERE election_id = ?) + " +
                     "(SELECT COALESCE(SUM(offline_votes), 0) FROM candidates WHERE election_id = ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, electionId);
            stmt.setInt(2, electionId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}
