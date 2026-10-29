package com.voting.dao;

import com.voting.model.Candidate;
import com.voting.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CandidateDAO {

    public boolean addCandidate(Candidate candidate) {
        String sql = "INSERT INTO candidates (election_id, name, manifesto, symbol_url, photo_url) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, candidate.getElectionId());
            stmt.setString(2, candidate.getName());
            stmt.setString(3, candidate.getManifesto());
            stmt.setString(4, candidate.getSymbolUrl());
            stmt.setString(5, candidate.getPhotoUrl());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Candidate> getCandidatesByElectionId(int electionId) {
        List<Candidate> candidates = new ArrayList<>();
        String sql = "SELECT * FROM candidates WHERE election_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, electionId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Candidate c = new Candidate();
                c.setId(rs.getInt("id"));
                c.setElectionId(rs.getInt("election_id"));
                c.setName(rs.getString("name"));
                c.setManifesto(rs.getString("manifesto"));
                c.setSymbolUrl(rs.getString("symbol_url"));
                c.setPhotoUrl(rs.getString("photo_url"));
                c.setOfflineVotes(rs.getInt("offline_votes"));
                candidates.add(c);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return candidates;
    }

    public boolean deleteCandidate(int id) {
        String sql = "DELETE FROM candidates WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateOfflineVotes(int candidateId, int offlineVotes) {
        String sql = "UPDATE candidates SET offline_votes = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, offlineVotes);
            stmt.setInt(2, candidateId);

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
