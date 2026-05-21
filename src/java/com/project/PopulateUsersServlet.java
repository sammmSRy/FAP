package com.project;

import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class PopulateUsersServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain");
        PrintWriter out = response.getWriter();

        try {
            // Read encryption settings from DD
            String secretKey = getServletContext().getInitParameter("secretKey");
            String cipherAlgo = getServletContext().getInitParameter("cipherAlgorithm");

            // Derby connection (same as other servlets)
            String driver = getServletConfig().getInitParameter("dbDriver");
            String url = getServletConfig().getInitParameter("dbURL");
            String dbUser = getServletConfig().getInitParameter("dbUser");
            String dbPass = getServletConfig().getInitParameter("dbPass");

            Class.forName(driver);
            Connection conn = DriverManager.getConnection(url, dbUser, dbPass);

            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO USERS (username, password, role) VALUES (?, ?, ?)");

            int count = 0;
            for (int i = 1; i <= 50; i++) {
                String username = "user" + String.format("%03d", i);   // user001 … user050
                String plainPass = "pass" + i;                         // pass1 … pass50
                String encrypted = CryptoUtil.encrypt(plainPass, secretKey, cipherAlgo);
                String role = "guest";

                ps.setString(1, username);
                ps.setString(2, encrypted);
                ps.setString(3, role);
                ps.executeUpdate();
                count++;
            }

            ps.close();
            conn.close();

            out.println("SUCCESS: " + count + " users inserted into Derby (USERS table).");
            out.println("You may now remove this servlet from web.xml and delete the .java file.");

        } catch (Exception e) {
            e.printStackTrace(out);
        }
    }
}