package com.voting.controller;

import com.voting.dao.UserDAO;
import com.voting.model.User;
import com.voting.util.TwoFactorAuthUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/setup-2fa")
public class TwoFactorSetupServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        User user = (User) session.getAttribute("user");
        
        // Generate new secret for setup
        String newSecret = TwoFactorAuthUtil.generateSecret();
        String qrCodeUri = TwoFactorAuthUtil.getQrCodeImageUri(newSecret, user.getEmail());

        session.setAttribute("setupTotpSecret", newSecret);
        request.setAttribute("qrCodeUri", qrCodeUri);
        request.setAttribute("secret", newSecret);

        request.getRequestDispatcher("/jsp/common/setup_2fa.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        User user = (User) session.getAttribute("user");
        String setupSecret = (String) session.getAttribute("setupTotpSecret");
        String code = request.getParameter("code");

        if (setupSecret != null && code != null && TwoFactorAuthUtil.verifyCode(setupSecret, code)) {
            // Success! Save secret to DB
            if (userDAO.updateTotpSecret(user.getId(), setupSecret)) {
                user.setTotpSecret(setupSecret);
                session.removeAttribute("setupTotpSecret");
                
                String dash = "ADMIN".equals(user.getRole()) ? "/admin/dashboard" : "/voter/dashboard";
                response.sendRedirect(request.getContextPath() + dash + "?msg=2FA Enabled Successfully");
            } else {
                request.setAttribute("error", "Database error while enabling 2FA.");
                request.getRequestDispatcher("/jsp/common/setup_2fa.jsp").forward(request, response);
            }
        } else {
            // Failed
            request.setAttribute("error", "Invalid code. Please try again.");
            request.setAttribute("qrCodeUri", TwoFactorAuthUtil.getQrCodeImageUri(setupSecret, user.getEmail()));
            request.setAttribute("secret", setupSecret);
            request.getRequestDispatcher("/jsp/common/setup_2fa.jsp").forward(request, response);
        }
    }
}
