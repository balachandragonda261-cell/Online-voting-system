package com.voting.model;

public class Candidate {
    private int id;
    private int electionId;
    private String name;
    private String manifesto;
    private String symbolUrl;
    private String photoUrl;
    private int offlineVotes;

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getElectionId() { return electionId; }
    public void setElectionId(int electionId) { this.electionId = electionId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getManifesto() { return manifesto; }
    public void setManifesto(String manifesto) { this.manifesto = manifesto; }
    public String getSymbolUrl() { return symbolUrl; }
    public void setSymbolUrl(String symbolUrl) { this.symbolUrl = symbolUrl; }
    public String getPhotoUrl() { return photoUrl; }
    public void setPhotoUrl(String photoUrl) { this.photoUrl = photoUrl; }
    public int getOfflineVotes() { return offlineVotes; }
    public void setOfflineVotes(int offlineVotes) { this.offlineVotes = offlineVotes; }
}
