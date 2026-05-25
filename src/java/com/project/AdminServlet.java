package com.project;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.http.*;

public class AdminServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        
        if (session == null || session.getAttribute("user") == null || !"admin".equals(session.getAttribute("role"))) {
            response.sendRedirect("error_session.jsp");
            return;
        }

        String action = request.getParameter("action");
        String targetUser = request.getParameter("targetUser");
        String targetPass = request.getParameter("targetPass");
        String targetRole = request.getParameter("targetRole");
        String currentUser = (String) session.getAttribute("user");

        try {
            // Retrieve encryption properties from DD
            String secretKey = getServletContext().getInitParameter("secretKey");
            String cipherAlgorithm = getServletContext().getInitParameter("cipherAlgorithm");

            String driver = getServletConfig().getInitParameter("dbDriver");
            String url = getServletConfig().getInitParameter("dbURL");
            String dbUser = getServletConfig().getInitParameter("dbUser");
            String dbPass = getServletConfig().getInitParameter("dbPass");

            Class.forName(driver);
            Connection conn = DriverManager.getConnection(url, dbUser, dbPass);
            PreparedStatement ps = null;

            if ("delete".equals(action)) {
                if (!targetUser.equals(currentUser)) {
                    ps = conn.prepareStatement("DELETE FROM USERS WHERE username = ?");
                    ps.setString(1, targetUser);
                    ps.executeUpdate();
                }
            } 
            else if ("insert".equals(action)) {
                String encryptedPass = CryptoUtil.encrypt(targetPass, secretKey, cipherAlgorithm);
                // UPDATED: include created_date for time-bound reports
                ps = conn.prepareStatement("INSERT INTO USERS (username, password, role, created_date) VALUES (?, ?, ?, CURRENT_DATE)");
                ps.setString(1, targetUser);
                ps.setString(2, encryptedPass);
                ps.setString(3, targetRole);
                ps.executeUpdate();
            } 
            else if ("update".equals(action)) {
                String encryptedPass = CryptoUtil.encrypt(targetPass, secretKey, cipherAlgorithm);
                ps = conn.prepareStatement("UPDATE USERS SET password = ?, role = ? WHERE username = ?");
                ps.setString(1, encryptedPass);
                ps.setString(2, targetRole);
                ps.setString(3, targetUser);
                ps.executeUpdate();
            }

            if (ps != null) ps.close();
            conn.close();
            
            response.sendRedirect("success.jsp");

        } catch (Exception e) {
            e.printStackTrace();   // still log to server console
            response.sendRedirect("error_db.jsp");   // user-friendly redirect
        }
    }
}