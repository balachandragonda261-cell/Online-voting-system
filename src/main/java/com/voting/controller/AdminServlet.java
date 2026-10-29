package com.voting.controller;

import com.voting.dao.CandidateDAO;
import com.voting.dao.ElectionDAO;
import com.voting.dao.UserDAO;
import com.voting.dao.VoteDAO;
import com.voting.dao.AuditLogDAO;
import com.voting.model.Candidate;
import com.voting.model.Election;
import com.voting.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import com.voting.dao.SMSDAO;

@WebServlet("/admin/*")
public class AdminServlet extends HttpServlet {

    private UserDAO userDAO;
    private ElectionDAO electionDAO;
    private CandidateDAO candidateDAO;
    private AuditLogDAO auditLogDAO;
    private VoteDAO voteDAO;
    private SMSDAO smsDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        electionDAO = new ElectionDAO();
        candidateDAO = new CandidateDAO();
        auditLogDAO = new AuditLogDAO();
        voteDAO = new VoteDAO();
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
            case "/elections":
                showElections(request, response);
                break;
            case "/users":
                showUsers(request, response);
                break;
            case "/candidates":
                showCandidates(request, response);
                break;
            case "/eligibility":
                showEligibility(request, response);
                break;
            case "/offlineVotes":
                showOfflineVotes(request, response);
                break;
            case "/sms":
                showSMSPage(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        switch (action) {
            case "createElection":
                createElection(request, response);
                break;
            case "updateElectionStatus":
                updateElectionStatus(request, response);
                break;
            case "updateUserStatus":
                updateUserStatus(request, response);
                break;
            case "addCandidate":
                addCandidate(request, response);
                break;
            case "removeCandidate":
                removeCandidate(request, response);
                break;
            case "declareWinner":
                declareWinner(request, response);
                break;
            case "updateEligibility":
                updateEligibility(request, response);
                break;
            case "updateOfflineVotes":
                updateOfflineVotes(request, response);
                break;
            case "deleteElection":
                deleteElection(request, response);
                break;
            case "sendSMS":
                sendSMS(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
        }
    }

    private void showDashboard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("elections", electionDAO.getAllElections());
        request.setAttribute("users", userDAO.getAllUsers());
        request.setAttribute("auditLogs", auditLogDAO.getLogs());
        request.getRequestDispatcher("/jsp/admin/dashboard.jsp").forward(request, response);
    }

    private void showElections(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("elections", electionDAO.getAllElections());
        request.getRequestDispatcher("/jsp/admin/manage_elections.jsp").forward(request, response);
    }

    private void showUsers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("users", userDAO.getAllUsers());
        request.getRequestDispatcher("/jsp/admin/manage_users.jsp").forward(request, response);
    }

    private void showCandidates(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int electionId = Integer.parseInt(request.getParameter("electionId"));
        request.setAttribute("election", electionDAO.getElectionById(electionId));
        request.setAttribute("candidates", candidateDAO.getCandidatesByElectionId(electionId));
        request.getRequestDispatcher("/jsp/admin/manage_candidates.jsp").forward(request, response);
    }

    private void showEligibility(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int electionId = Integer.parseInt(request.getParameter("electionId"));
        
        List<User> allUsers = userDAO.getAllUsers();
        List<User> voters = new java.util.ArrayList<>();
        for (User u : allUsers) {
            if ("VOTER".equals(u.getRole())) {
                voters.add(u);
            }
        }
        
        request.setAttribute("election", electionDAO.getElectionById(electionId));
        request.setAttribute("voters", voters);
        request.setAttribute("eligibleVoterIds", electionDAO.getEligibleVoterIds(electionId));
        request.getRequestDispatcher("/jsp/admin/manage_eligibility.jsp").forward(request, response);
    }

    private void showOfflineVotes(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int electionId = Integer.parseInt(request.getParameter("electionId"));
        request.setAttribute("election", electionDAO.getElectionById(electionId));
        request.setAttribute("candidates", candidateDAO.getCandidatesByElectionId(electionId));
        request.getRequestDispatcher("/jsp/admin/manage_offline_votes.jsp").forward(request, response);
    }

    private void createElection(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String startTimeStr = request.getParameter("startTime");
        String endTimeStr = request.getParameter("endTime");

        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
        try {
            Date parsedStart = dateFormat.parse(startTimeStr);
            Date parsedEnd = dateFormat.parse(endTimeStr);

            Election election = new Election();
            election.setTitle(title);
            election.setDescription(description);
            election.setStartTime(new Timestamp(parsedStart.getTime()));
            election.setEndTime(new Timestamp(parsedEnd.getTime()));
            election.setStatus("DRAFT");

            if (electionDAO.addElection(election)) {
                logAdminAction(request, "CREATED_ELECTION: " + title);
            }
        } catch (ParseException e) {
            e.printStackTrace();
        }
        response.sendRedirect(request.getContextPath() + "/admin/elections");
    }

    private void updateElectionStatus(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int electionId = Integer.parseInt(request.getParameter("electionId"));
        String status = request.getParameter("status");
        
        if (electionDAO.updateElectionStatus(electionId, status)) {
            logAdminAction(request, "UPDATED_ELECTION_STATUS: ID=" + electionId + " to " + status);
        }
        response.sendRedirect(request.getContextPath() + "/admin/elections");
    }

    private void deleteElection(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int electionId = Integer.parseInt(request.getParameter("electionId"));
        
        if (electionDAO.deleteElection(electionId)) {
            logAdminAction(request, "DELETED_ELECTION: ID=" + electionId);
        }
        response.sendRedirect(request.getContextPath() + "/admin/elections");
    }

    private void updateUserStatus(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int userId = Integer.parseInt(request.getParameter("userId"));
        String status = request.getParameter("status");

        if (userDAO.updateUserStatus(userId, status)) {
            logAdminAction(request, "UPDATED_USER_STATUS: ID=" + userId + " to " + status);
        }
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }

    private void addCandidate(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int electionId = Integer.parseInt(request.getParameter("electionId"));
        String name = request.getParameter("name");
        String manifesto = request.getParameter("manifesto");
        
        // Simulating upload URLs for now
        String symbolUrl = "/img/default_symbol.png"; 
        String photoUrl = "/img/default_photo.png";

        Candidate candidate = new Candidate();
        candidate.setElectionId(electionId);
        candidate.setName(name);
        candidate.setManifesto(manifesto);
        candidate.setSymbolUrl(symbolUrl);
        candidate.setPhotoUrl(photoUrl);

        if (candidateDAO.addCandidate(candidate)) {
            logAdminAction(request, "ADDED_CANDIDATE: " + name + " for Election " + electionId);
        }
        response.sendRedirect(request.getContextPath() + "/admin/candidates?electionId=" + electionId);
    }

    private void removeCandidate(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int candidateId = Integer.parseInt(request.getParameter("candidateId"));
        int electionId = Integer.parseInt(request.getParameter("electionId"));

        if (candidateDAO.deleteCandidate(candidateId)) {
            logAdminAction(request, "REMOVED_CANDIDATE: ID=" + candidateId + " from Election " + electionId);
        }
        response.sendRedirect(request.getContextPath() + "/admin/candidates?electionId=" + electionId);
    }

    private void declareWinner(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int electionId = Integer.parseInt(request.getParameter("electionId"));
        
        java.util.Map<Integer, Integer> voteCounts = voteDAO.getVoteCountByCandidate(electionId);
        int winnerId = -1;
        int maxVotes = -1;
        boolean isTie = false;
        
        for (java.util.Map.Entry<Integer, Integer> entry : voteCounts.entrySet()) {
            if (entry.getValue() > maxVotes) {
                maxVotes = entry.getValue();
                winnerId = entry.getKey();
                isTie = false;
            } else if (entry.getValue() == maxVotes && maxVotes > 0) {
                isTie = true;
            }
        }
        
        if (isTie) {
            winnerId = -1;
        }
        
        if (winnerId != -1) {
            if (electionDAO.declareWinner(electionId, winnerId)) {
                logAdminAction(request, "DECLARED_WINNER: Candidate " + winnerId + " for Election " + electionId);
            }
        } else if (isTie || maxVotes == 0) {
            // maxVotes == 0 means no one voted
            if (electionDAO.declareWinner(electionId, -1)) {
                logAdminAction(request, "DECLARED_WINNER_TIE_OR_NO_VOTES: Election " + electionId);
            }
        }
        response.sendRedirect(request.getContextPath() + "/admin/elections");
    }

    private void updateEligibility(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int electionId = Integer.parseInt(request.getParameter("electionId"));
        boolean isPrivate = Boolean.parseBoolean(request.getParameter("isPrivate"));
        String[] voterIdStrs = request.getParameterValues("voterIds");
        
        List<Integer> voterIds = new java.util.ArrayList<>();
        if (voterIdStrs != null) {
            for (String vId : voterIdStrs) {
                voterIds.add(Integer.parseInt(vId));
            }
        }
        
        electionDAO.updateElectionPrivacy(electionId, isPrivate);
        
        if (electionDAO.updateElectionVoters(electionId, voterIds)) {
            logAdminAction(request, "UPDATED_ELIGIBILITY: Election " + electionId + " (Private: " + isPrivate + ") with " + voterIds.size() + " voters");
        }
        response.sendRedirect(request.getContextPath() + "/admin/eligibility?electionId=" + electionId);
    }

    private void updateOfflineVotes(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int electionId = Integer.parseInt(request.getParameter("electionId"));
        
        List<Candidate> candidates = candidateDAO.getCandidatesByElectionId(electionId);
        for (Candidate c : candidates) {
            String paramName = "offline_votes_" + c.getId();
            String paramValue = request.getParameter(paramName);
            if (paramValue != null && !paramValue.isEmpty()) {
                int offlineVotes = Integer.parseInt(paramValue);
                candidateDAO.updateOfflineVotes(c.getId(), offlineVotes);
            }
        }
        
        logAdminAction(request, "UPDATED_OFFLINE_VOTES: Election " + electionId);
        response.sendRedirect(request.getContextPath() + "/admin/elections");
    }

    private void showSMSPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int electionId = Integer.parseInt(request.getParameter("electionId"));
        Election election = electionDAO.getElectionById(electionId);
        
        List<User> voters = new java.util.ArrayList<>();
        if (election.isPrivate()) {
            List<Integer> eligibleVoterIds = electionDAO.getEligibleVoterIds(electionId);
            for (int vId : eligibleVoterIds) {
                User u = userDAO.getUserById(vId);
                if (u != null && "VOTER".equals(u.getRole())) {
                    voters.add(u);
                }
            }
        } else {
            List<User> allUsers = userDAO.getAllUsers();
            for (User u : allUsers) {
                if ("VOTER".equals(u.getRole())) {
                    voters.add(u);
                }
            }
        }
        
        request.setAttribute("election", election);
        request.setAttribute("voters", voters);
        request.getRequestDispatcher("/jsp/admin/send_sms.jsp").forward(request, response);
    }

    private void sendSMS(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int electionId = Integer.parseInt(request.getParameter("electionId"));
        String message = request.getParameter("message");
        
        Election election = electionDAO.getElectionById(electionId);
        List<User> voters = new java.util.ArrayList<>();
        if (election.isPrivate()) {
            List<Integer> eligibleVoterIds = electionDAO.getEligibleVoterIds(electionId);
            for (int vId : eligibleVoterIds) {
                User u = userDAO.getUserById(vId);
                if (u != null && "VOTER".equals(u.getRole())) {
                    voters.add(u);
                }
            }
        } else {
            List<User> allUsers = userDAO.getAllUsers();
            for (User u : allUsers) {
                if ("VOTER".equals(u.getRole())) {
                    voters.add(u);
                }
            }
        }
        
        // Simulating the SMS dispatch
        for (User voter : voters) {
            System.out.println("[SMS Broadcaster] TO: " + voter.getName() + " (" + voter.getEmail() + ") MESSAGE: " + message);
            smsDAO.logSMS(electionId, voter.getId(), message, "SENT");
        }
        
        logAdminAction(request, "BROADCASTED_SMS: Election ID=" + electionId + " to " + voters.size() + " voters: " + message);
        
        response.sendRedirect(request.getContextPath() + "/admin/elections?message=SMS broadcasted successfully to " + voters.size() + " voters!");
    }

    private void logAdminAction(HttpServletRequest request, String actionStr) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            User admin = (User) session.getAttribute("user");
            if (admin != null) {
                auditLogDAO.logAction(admin.getId(), actionStr, request.getRemoteAddr());
            }
        }
    }
}
