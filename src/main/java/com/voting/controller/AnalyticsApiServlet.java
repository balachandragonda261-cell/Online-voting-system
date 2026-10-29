package com.voting.controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.voting.dao.CandidateDAO;
import com.voting.dao.ElectionDAO;
import com.voting.dao.VoteDAO;
import com.voting.model.Candidate;
import com.voting.model.Election;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet("/api/analytics/live")
public class AnalyticsApiServlet extends HttpServlet {

    private ElectionDAO electionDAO;
    private CandidateDAO candidateDAO;
    private VoteDAO voteDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        electionDAO = new ElectionDAO();
        candidateDAO = new CandidateDAO();
        voteDAO = new VoteDAO();
        gson = new Gson();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Note: For full enterprise security, we should check if the user is authenticated 
        // and authorized (e.g. JWT or session). Since we are currently relying on standard sessions:
        // We could restrict this to ADMIN, or allow it for public live results. Let's make it public for results.
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String electionIdParam = request.getParameter("electionId");
        if (electionIdParam == null || electionIdParam.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"electionId is required\"}");
            return;
        }

        try {
            int electionId = Integer.parseInt(electionIdParam);
            Election election = electionDAO.getElectionById(electionId);

            if (election == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"error\":\"Election not found\"}");
                return;
            }

            List<Candidate> candidates = candidateDAO.getCandidatesByElectionId(electionId);
            Map<Integer, Integer> voteCounts = voteDAO.getVoteCountByCandidate(electionId);
            int totalVotes = voteDAO.getTotalVotesByElection(electionId);

            // Construct JSON Response
            List<JsonObject> candidateDataList = new ArrayList<>();
            for (Candidate candidate : candidates) {
                JsonObject cObj = new JsonObject();
                cObj.addProperty("id", candidate.getId());
                cObj.addProperty("name", candidate.getName());
                cObj.addProperty("votes", voteCounts.getOrDefault(candidate.getId(), 0));
                
                double percentage = totalVotes > 0 ? (voteCounts.getOrDefault(candidate.getId(), 0) * 100.0 / totalVotes) : 0.0;
                cObj.addProperty("percentage", percentage);
                
                candidateDataList.add(cObj);
            }

            JsonObject jsonResponse = new JsonObject();
            jsonResponse.addProperty("electionId", electionId);
            jsonResponse.addProperty("title", election.getTitle());
            jsonResponse.addProperty("status", election.getStatus());
            jsonResponse.addProperty("totalVotes", totalVotes);
            jsonResponse.add("candidates", gson.toJsonTree(candidateDataList));

            response.getWriter().write(gson.toJson(jsonResponse));

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Invalid electionId format\"}");
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Internal Server Error\"}");
        }
    }
}
