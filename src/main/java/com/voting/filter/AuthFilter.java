package com.voting.filter;

import com.voting.model.User;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(urlPatterns = {"/admin/*", "/voter/*"})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        String path = req.getRequestURI().substring(req.getContextPath().length());

        boolean loggedIn = (session != null && session.getAttribute("user") != null);
        
        if (loggedIn) {
            User user = (User) session.getAttribute("user");
            
            // Check roles
            if (path.startsWith("/admin/") && !"ADMIN".equals(user.getRole())) {
                res.sendRedirect(req.getContextPath() + "/auth?action=login&error=Unauthorized access");
                return;
            }
            if (path.startsWith("/voter/") && "ADMIN".equals(user.getRole())) {
                // Admin trying to access voter path? Redirect to admin dashboard
                res.sendRedirect(req.getContextPath() + "/admin/dashboard");
                return;
            }
            
            chain.doFilter(request, response);
        } else {
            res.sendRedirect(req.getContextPath() + "/auth?action=login");
        }
    }

    @Override
    public void destroy() {
    }
}
