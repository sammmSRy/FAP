package com.project;

import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String user = request.getParameter("username");
        String pass = request.getParameter("password");
        String userCaptcha = request.getParameter("user_captcha");

        try {
            if (user == null || pass == null || user.isEmpty() || pass.isEmpty()) {
                throw new NullValueException("Credentials cannot be blank.");
            }

            // 1. Captcha Verification (Using Captcha2609 Logic)
            HttpSession session = request.getSession();
            String sessionCaptcha = (String) session.getAttribute("captchaVal");
            
            if (sessionCaptcha == null || userCaptcha == null || !sessionCaptcha.equals(userCaptcha)) {
                response.sendRedirect("error_captcha.jsp");
                return;
            }

            // 2. Encryption Setup
            String secretKey = getServletContext().getInitParameter("secretKey");
            String cipherAlgorithm = getServletContext().getInitParameter("cipherAlgorithm");
            String encryptedPass = CryptoUtil.encrypt(pass, secretKey, cipherAlgorithm);

            // 3. Database Validation
            String driver = getServletConfig().getInitParameter("dbDriver");
            String url = getServletConfig().getInitParameter("dbURL");
            String dbUser = getServletConfig().getInitParameter("dbUser");
            String dbPass = getServletConfig().getInitParameter("dbPass");

            Class.forName(driver);
            Connection conn = DriverManager.getConnection(url, dbUser, dbPass);
            
            PreparedStatement ps = conn.prepareStatement("SELECT * FROM USERS WHERE username = ?");
            ps.setString(1, user);
            ResultSet rs = ps.executeQuery();

            if (!rs.next()) {
                if (pass.isEmpty()) response.sendRedirect("error_1.jsp");
                else response.sendRedirect("error_3.jsp");
            } else {
                String dbPassValue = rs.getString("password");
                String dbRole = rs.getString("role");

                // Compare ENCRYPTED input against ENCRYPTED database value
                if (dbPassValue.equals(encryptedPass)) {
                    session.setAttribute("user", user);
                    session.setAttribute("role", dbRole);
                    response.sendRedirect("success.jsp");
                } else {
                    response.sendRedirect("error_2.jsp"); 
                }
            }
            conn.close();
        } catch (NullValueException e) {
            response.sendRedirect("noLoginCredentials.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error_4.jsp"); 
        }
    }
}