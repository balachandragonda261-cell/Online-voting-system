package com.voting.controller;

import com.voting.dao.AuditLogDAO;
import com.voting.dao.UserDAO;
import com.voting.model.User;
import com.voting.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.UUID;

@WebServlet("/auth")
public class AuthServlet extends HttpServlet {

    private UserDAO userDAO;
    private AuditLogDAO auditLogDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        auditLogDAO = new AuditLogDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "login";
        }

        switch (action) {
            case "login":
                request.getRequestDispatcher("/jsp/common/login.jsp").forward(request, response);
                break;
            case "register":
                request.getRequestDispatcher("/jsp/common/register.jsp").forward(request, response);
                break;
            case "logout":
                logout(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/index.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("login".equals(action)) {
            login(request, response);
        } else if ("register".equals(action)) {
            register(request, response);
        }
    }

    private void login(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        User user = userDAO.getUserByEmail(email);

        if (user != null && PasswordUtil.checkPassword(password, user.getPasswordHash())) {
            if ("REJECTED".equals(user.getStatus())) {
                request.setAttribute("error", "Your account has been rejected.");
                request.getRequestDispatcher("/jsp/common/login.jsp").forward(request, response);
                return;
            } else if ("PENDING".equals(user.getStatus())) {
                request.setAttribute("error", "Your account is pending approval by an admin.");
                request.getRequestDispatcher("/jsp/common/login.jsp").forward(request, response);
                return;
            }
            // Session Fixation Protection
            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }
            HttpSession session = request.getSession(true);

            // Check if 2FA is enabled
            if (user.getTotpSecret() != null && !user.getTotpSecret().trim().isEmpty()) {
                session.setAttribute("tempUser", user);
                response.sendRedirect(request.getContextPath() + "/jsp/common/2fa.jsp");
                return;
            }

            // Normal login (2FA not enabled)
            session.setAttribute("user", user);

            auditLogDAO.logAction(user.getId(), "LOGIN", request.getRemoteAddr());

            if ("ADMIN".equals(user.getRole())) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            } else {
                response.sendRedirect(request.getContextPath() + "/voter/dashboard");
            }
        } else {
            request.setAttribute("error", "Invalid email or password.");
            request.getRequestDispatcher("/jsp/common/login.jsp").forward(request, response);
        }
    }

    private void register(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (userDAO.getUserByEmail(email) != null) {
            request.setAttribute("error", "Email is already registered.");
            request.getRequestDispatcher("/jsp/common/register.jsp").forward(request, response);
            return;
        }

        User user = new User();
        user.setName(name);
        user.setEmail(email);
        user.setPasswordHash(PasswordUtil.hashPassword(password));
        user.setRole("VOTER");
        user.setStatus("PENDING"); // Requires admin approval

        if (userDAO.registerUser(user)) {
            User registeredUser = userDAO.getUserByEmail(email);
            auditLogDAO.logAction(registeredUser.getId(), "REGISTER", request.getRemoteAddr());
            request.setAttribute("message", "Registration successful. Please wait for admin approval.");
            request.getRequestDispatcher("/jsp/common/login.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Registration failed. Please try again.");
            request.getRequestDispatcher("/jsp/common/register.jsp").forward(request, response);
        }
    }

    private void logout(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            User user = (User) session.getAttribute("user");
            if (user != null) {
                auditLogDAO.logAction(user.getId(), "LOGOUT", request.getRemoteAddr());
            }
            session.invalidate();
        }
        response.sendRedirect(request.getContextPath() + "/auth?action=login&message=Logged out successfully");
    }
}
