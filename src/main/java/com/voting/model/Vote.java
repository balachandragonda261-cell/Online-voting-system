package com.voting.model;

import java.sql.Timestamp;

public class Vote {
    private int id;
    private int electionId;
    private int voterId;
    private int candidateId;
    private Timestamp voteTimestamp;
    private String previousHash;
    private String voteHash;

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getElectionId() { return electionId; }
    public void setElectionId(int electionId) { this.electionId = electionId; }
    public int getVoterId() { return voterId; }
    public void setVoterId(int voterId) { this.voterId = voterId; }
    public int getCandidateId() { return candidateId; }
    public void setCandidateId(int candidateId) { this.candidateId = candidateId; }
    public Timestamp getVoteTimestamp() { return voteTimestamp; }
    public void setVoteTimestamp(Timestamp voteTimestamp) { this.voteTimestamp = voteTimestamp; }
    public String getPreviousHash() { return previousHash; }
    public void setPreviousHash(String previousHash) { this.previousHash = previousHash; }
    public String getVoteHash() { return voteHash; }
    public void setVoteHash(String voteHash) { this.voteHash = voteHash; }
}
