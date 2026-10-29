package com.voting.controller;

import com.voting.dao.ElectionDAO;
import com.voting.dao.CandidateDAO;
import com.voting.dao.VoteDAO;
import com.voting.model.Election;
import com.voting.model.Candidate;
import com.voting.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.ArrayList;

@WebServlet("/api/chatbot")
public class AIChatServlet extends HttpServlet {

    private ElectionDAO electionDAO;
    private CandidateDAO candidateDAO;
    private VoteDAO voteDAO;

    @Override
    public void init() throws ServletException {
        electionDAO = new ElectionDAO();
        candidateDAO = new CandidateDAO();
        voteDAO = new VoteDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;

        String userMessage = request.getParameter("message");
        if (userMessage == null) userMessage = "";
        userMessage = userMessage.toLowerCase().trim();

        String reply;

        // 1. Check if user is logged in
        if (user == null) {
            if (userMessage.contains("hello") || userMessage.contains("hi") || userMessage.contains("hey")) {
                reply = "Hello! I am your AI Voter Assistant. Please log in to your account to view your eligible elections and cast your votes safely!";
            } else {
                reply = "To assist you with your personalized voting options, active elections, or ballot receipt, please log in first. General Help: We use blockchain and biometrics to keep your vote 100% secure.";
            }
        } else if ("ADMIN".equals(user.getRole())) {
            reply = "Welcome, Admin " + user.getName() + "! As an Administrator, you can manage users, candidates, and elections from your dashboard. Let me know if you need voter-side help!";
        } else {
            // Logged-in Voter assistant logic
            String voterName = user.getName();
            int voterId = user.getId();

            if (userMessage.contains("hello") || userMessage.contains("hi") || userMessage.contains("hey")) {
                reply = "Hello, " + voterName + "! I'm your AI Voter Assistant. Ask me about your eligible elections, which elections you've already voted in, candidate details, or how to vote!";
            } else if (userMessage.contains("active") || userMessage.contains("election") || userMessage.contains("vote in") || userMessage.contains("available")) {
                List<Election> allElections = electionDAO.getElectionsForVoter(voterId);
                List<Integer> votedIds = voteDAO.getVotedElectionIds(voterId);
                
                List<String> livePending = new ArrayList<>();
                List<String> upcoming = new ArrayList<>();
                List<String> completed = new ArrayList<>();

                for (Election el : allElections) {
                    if ("LIVE".equals(el.getStatus())) {
                        if (votedIds.contains(el.getId())) {
                            completed.add("'" + el.getTitle() + "' (Voted)");
                        } else {
                            livePending.add("'" + el.getTitle() + "' (Tap to Vote!)");
                        }
                    } else if ("PUBLISHED".equals(el.getStatus())) {
                        upcoming.add("'" + el.getTitle() + "' (Upcoming)");
                    }
                }

                StringBuilder sb = new StringBuilder();
                if (livePending.isEmpty() && upcoming.isEmpty()) {
                    sb.append("Hi ").append(voterName).append(", there are currently no new open elections for you.");
                    if (!completed.isEmpty()) {
                        sb.append(" You have already successfully participated in all available elections: ").append(String.join(", ", completed)).append(".");
                    }
                } else {
                    sb.append("Here is your customized election status:\\n");
                    if (!livePending.isEmpty()) {
                        sb.append("• **LIVE elections you can vote in:** ").append(String.join(", ", livePending)).append("\\n");
                    }
                    if (!upcoming.isEmpty()) {
                        sb.append("• **Upcoming elections:** ").append(String.join(", ", upcoming)).append("\\n");
                    }
                    if (!completed.isEmpty()) {
                        sb.append("• **Elections you already voted in:** ").append(String.join(", ", completed)).append("\\n");
                    }
                }
                reply = sb.toString();
            } else if (userMessage.contains("voted") || userMessage.contains("status") || userMessage.contains("history") || userMessage.contains("participated")) {
                List<Election> allElections = electionDAO.getElectionsForVoter(voterId);
                List<Integer> votedIds = voteDAO.getVotedElectionIds(voterId);
                List<String> votedList = new ArrayList<>();
                List<String> pendingList = new ArrayList<>();

                for (Election el : allElections) {
                    if ("LIVE".equals(el.getStatus())) {
                        if (votedIds.contains(el.getId())) {
                            votedList.add(el.getTitle());
                        } else {
                            pendingList.add(el.getTitle());
                        }
                    }
                }

                if (votedList.isEmpty()) {
                    reply = "You haven't cast any votes yet! You have " + pendingList.size() + " live election(s) waiting for you to participate.";
                } else {
                    reply = "Excellent job, " + voterName + "! You have successfully cast your secure blockchain vote in the following election(s): " + String.join(", ", votedList) + "." +
                            (pendingList.isEmpty() ? " You are fully up to date!" : " You still have pending election(s): " + String.join(", ", pendingList) + ".");
                }
            } else if (userMessage.contains("candidate") || userMessage.contains("who is running") || userMessage.contains("contestants")) {
                List<Election> allElections = electionDAO.getElectionsForVoter(voterId);
                Election matchingElection = null;
                
                // Try to find if user specified a name of an election
                for (Election el : allElections) {
                    if (userMessage.contains(el.getTitle().toLowerCase())) {
                        matchingElection = el;
                        break;
                    }
                }

                if (matchingElection == null) {
                    // Try to find any active/live election to list candidates for
                    for (Election el : allElections) {
                        if ("LIVE".equals(el.getStatus())) {
                            matchingElection = el;
                            break;
                        }
                    }
                }

                if (matchingElection != null) {
                    List<Candidate> candidates = candidateDAO.getCandidatesByElectionId(matchingElection.getId());
                    if (candidates.isEmpty()) {
                        reply = "There are currently no candidates registered for the election '" + matchingElection.getTitle() + "'.";
                    } else {
                        List<String> names = new ArrayList<>();
                        for (Candidate c : candidates) {
                            names.add(c.getName() + " (" + (c.getManifesto() != null ? c.getManifesto() : "No manifesto") + ")");
                        }
                        reply = "Candidates for '" + matchingElection.getTitle() + "':\\n" + String.join("\\n", names);
                    }
                } else {
                    reply = "I couldn't find any active election matching that title. Please specify which election you are asking about (e.g., 'who are the candidates for Student Council'?).";
                }
            } else if (userMessage.contains("how to vote") || userMessage.contains("how do i vote")) {
                reply = "Hi " + voterName + "! To vote, go to your Dashboard, find any 'LIVE' election, and click the 'Cast Vote' button. Then, choose your candidate, verify your identity via the biometric scanner, and submit! Your vote is securely recorded using cryptographic blockchain hashing.";
            } else if (userMessage.contains("safe") || userMessage.contains("secure") || userMessage.contains("blockchain")) {
                reply = "Absolutely! Every vote cast on VoteSecure is protected by AES/RSA encryption, SHA-256 blockchain chaining (your receipt hash links to the previous vote), and strict Biometric KYC checks. Your vote cannot be tampered with or deleted.";
            } else if (userMessage.contains("receipt") || userMessage.contains("proof") || userMessage.contains("verification")) {
                reply = "Whenever you cast a vote, you receive a secure cryptographic receipt containing a SHA-256 vote hash. This is your digital proof that your vote is entered into the blockchain. You can view past receipts in your dashboard!";
            } else {
                reply = "I'm here to help, " + voterName + "! Try asking me: 'What are my active elections?', 'Have I voted yet?', 'Who is running for Student Council?', or 'How is my vote secured?'.";
            }
        }

        // Return JSON with safe escaping
        String escapedReply = escapeJson(reply);
        String jsonResponse = "{\"reply\": \"" + escapedReply + "\"}";
        response.getWriter().write(jsonResponse);
    }

    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}
