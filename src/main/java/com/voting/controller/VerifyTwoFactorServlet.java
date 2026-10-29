package com.voting.controller;

import com.voting.dao.AuditLogDAO;
import com.voting.model.User;
import com.voting.util.TwoFactorAuthUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/verify-2fa")
public class VerifyTwoFactorServlet extends HttpServlet {

    private AuditLogDAO auditLogDAO;

    @Override
    public void init() throws ServletException {
        auditLogDAO = new AuditLogDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("tempUser") == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        User tempUser = (User) session.getAttribute("tempUser");
        String code = request.getParameter("code");

        if (code != null && TwoFactorAuthUtil.verifyCode(tempUser.getTotpSecret(), code)) {
            // Success
            session.removeAttribute("tempUser");
            
            // Session Fixation Protection again just in case
            session.invalidate();
            HttpSession newSession = request.getSession(true);
            newSession.setAttribute("user", tempUser);

            auditLogDAO.logAction(tempUser.getId(), "LOGIN_2FA", request.getRemoteAddr());

            if ("ADMIN".equals(tempUser.getRole())) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            } else {
                response.sendRedirect(request.getContextPath() + "/voter/dashboard");
            }
        } else {
            // Failure
            request.setAttribute("error", "Invalid authentication code. Please try again.");
            request.getRequestDispatcher("/jsp/common/2fa.jsp").forward(request, response);
        }
    }
}
