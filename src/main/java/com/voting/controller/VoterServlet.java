package com.voting.controller;

import com.voting.dao.CandidateDAO;
import com.voting.dao.ElectionDAO;
import com.voting.dao.VoteDAO;
import com.voting.dao.AuditLogDAO;
import com.voting.model.Election;
import com.voting.model.User;
import com.voting.model.Vote;

import com.voting.dao.SMSDAO;
import com.voting.model.SMSLog;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.UUID;
import java.sql.Timestamp;

@WebServlet("/voter/*")
public class VoterServlet extends HttpServlet {

    private ElectionDAO electionDAO;
    private CandidateDAO candidateDAO;
    private VoteDAO voteDAO;
    private AuditLogDAO auditLogDAO;
    private SMSDAO smsDAO;

    @Override
    public void init() throws ServletException {
        electionDAO = new ElectionDAO();
        candidateDAO = new CandidateDAO();
        voteDAO = new VoteDAO();
        auditLogDAO = new AuditLogDAO();
        smsDAO = new SMSDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            pathInfo = "/dashboard";
        }

        switch (pathInfo) {
            case "/dashboard":
                showDashboard(request, response);
                break;
            case "/vote":
                showVotePage(request, response);
                break;
            case "/receipt":
                showReceipt(request, response);
                break;
            case "/results":
                showResults(request, response);
                break;
            case "/history":
                showHistory(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/voter/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("castVote".equals(action)) {
            castVote(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/voter/dashboard");
        }
    }

    private void showDashboard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User voter = session != null ? (User) session.getAttribute("user") : null;
        if (voter != null) {
            request.setAttribute("elections", electionDAO.getElectionsForVoter(voter.getId()));
            request.setAttribute("votedElectionIds", voteDAO.getVotedElectionIds(voter.getId()));
            request.setAttribute("smsLogs", smsDAO.getSMSLogsByVoter(voter.getId()));
        } else {
            request.setAttribute("elections", new java.util.ArrayList<Election>());
            request.setAttribute("votedElectionIds", new java.util.ArrayList<Integer>());
            request.setAttribute("smsLogs", new java.util.ArrayList<SMSLog>());
        }
        request.getRequestDispatcher("/jsp/voter/dashboard.jsp").forward(request, response);
    }

    private void showVotePage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int electionId = Integer.parseInt(request.getParameter("electionId"));
        Election election = electionDAO.getElectionById(electionId);
        
        HttpSession session = request.getSession(false);
        User voter = (User) session.getAttribute("user");
        
        if (voteDAO.hasVoted(electionId, voter.getId())) {
            request.setAttribute("error", "You have already cast your vote in this election.");
            showDashboard(request, response);
            return;
        }

        // Verify eligibility
        if (!electionDAO.isVoterEligible(electionId, voter.getId())) {
            request.setAttribute("error", "You are not authorized to participate in this election.");
            showDashboard(request, response);
            return;
        }

        // Verify if election is live
        if (!"LIVE".equals(election.getStatus())) {
            request.setAttribute("error", "This election is not currently live.");
            showDashboard(request, response);
            return;
        }
        
        // Verify time constraints
        long currentTime = System.currentTimeMillis();
        if (currentTime < election.getStartTime().getTime() || currentTime > election.getEndTime().getTime()) {
            request.setAttribute("error", "Voting is not allowed at this time.");
            showDashboard(request, response);
            return;
        }

        request.setAttribute("election", election);
        request.setAttribute("candidates", candidateDAO.getCandidatesByElectionId(electionId));
        request.getRequestDispatcher("/jsp/voter/vote.jsp").forward(request, response);
    }

    private void castVote(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        int electionId = Integer.parseInt(request.getParameter("electionId"));
        int candidateId = Integer.parseInt(request.getParameter("candidateId"));

        HttpSession session = request.getSession(false);
        User voter = (User) session.getAttribute("user");

        if (voteDAO.hasVoted(electionId, voter.getId())) {
            request.setAttribute("error", "You have already cast your vote in this election.");
            response.sendRedirect(request.getContextPath() + "/voter/dashboard");
            return;
        }

        if (!electionDAO.isVoterEligible(electionId, voter.getId())) {
            request.setAttribute("error", "You are not authorized to participate in this election.");
            response.sendRedirect(request.getContextPath() + "/voter/dashboard");
            return;
        }

        String previousHash = voteDAO.getLastVoteHash();
        String dataToHash = previousHash + electionId + voter.getId() + candidateId + System.currentTimeMillis();
        String newHash = com.voting.util.CryptoUtil.calculateSHA256(dataToHash);

        Vote vote = new Vote();
        vote.setElectionId(electionId);
        vote.setVoterId(voter.getId());
        vote.setCandidateId(candidateId);
        vote.setPreviousHash(previousHash);
        vote.setVoteHash(newHash); // Secure receipt

        if (voteDAO.castVote(vote)) {
            auditLogDAO.logAction(voter.getId(), "CAST_VOTE_ELECTION_" + electionId, request.getRemoteAddr());
            response.sendRedirect(request.getContextPath() + "/voter/receipt?hash=" + vote.getVoteHash());
        } else {
            request.setAttribute("error", "Failed to cast vote. Please try again.");
            request.getRequestDispatcher("/voter/dashboard").forward(request, response);
        }
    }

    private void showReceipt(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String hash = request.getParameter("hash");
        request.setAttribute("receiptHash", hash);
        request.getRequestDispatcher("/jsp/voter/receipt.jsp").forward(request, response);
    }

    private void showResults(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int electionId = Integer.parseInt(request.getParameter("electionId"));
        Election election = electionDAO.getElectionById(electionId);
        
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        boolean isAdmin = user != null && "ADMIN".equals(user.getRole());

        if (isAdmin) {
             response.sendRedirect(request.getContextPath() + "/admin/dashboard");
             return;
        }

        if ("LIVE".equals(election.getStatus()) || "DRAFT".equals(election.getStatus()) || "PUBLISHED".equals(election.getStatus()) || "CLOSED".equals(election.getStatus())) {
             request.setAttribute("error", "Results are not available until the election is published by the admin.");
             showDashboard(request, response);
             return;
        }

        request.setAttribute("election", election);
        request.setAttribute("candidates", candidateDAO.getCandidatesByElectionId(electionId));
        request.setAttribute("voteCounts", voteDAO.getVoteCountByCandidate(electionId));
        request.setAttribute("totalVotes", voteDAO.getTotalVotesByElection(electionId));
        
        request.getRequestDispatcher("/jsp/common/results.jsp").forward(request, response);
    }

    private void showHistory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User voter = session != null ? (User) session.getAttribute("user") : null;
        if (voter != null) {
            request.setAttribute("elections", electionDAO.getElectionsForVoter(voter.getId()));
        } else {
            request.setAttribute("elections", new java.util.ArrayList<Election>());
        }
        request.getRequestDispatcher("/jsp/voter/past_elections.jsp").forward(request, response);
    }
}
