package com.project;

import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class CourseServlet extends HttpServlet {

    // Helper: get MySQL connection from web.xml context params
    private Connection getConnection() throws Exception {
        ServletContext ctx = getServletContext();
        String driver = ctx.getInitParameter("mysqlDriver");
        String url = ctx.getInitParameter("mysqlURL");
        String user = ctx.getInitParameter("mysqlUser");
        String pass = ctx.getInitParameter("mysqlPass");

        Class.forName(driver);
        return DriverManager.getConnection(url, user, pass);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Security: only logged‑in users can access
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("error_session.jsp");
            return;
        }

        String action = request.getParameter("action");
        // For admin, only admin can delete/update? Usually yes, but we can restrict later if needed.
        // For now any logged‑in user can manage courses (you can add role check if needed).
        // But the requirement is "accessible only if the user is successfully logged in".
        // So we already check session.

        try (Connection conn = getConnection()) {
            if ("add".equals(action)) {
                String courseName = request.getParameter("courseName");
                String instructor = request.getParameter("instructor");
                String schedule = request.getParameter("schedule");

                PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO courses (course_name, instructor, schedule, created_date) VALUES (?, ?, ?, CURDATE())");
                ps.setString(1, courseName);
                ps.setString(2, instructor);
                ps.setString(3, schedule);
                ps.executeUpdate();

            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                PreparedStatement ps = conn.prepareStatement("DELETE FROM courses WHERE id = ?");
                ps.setInt(1, id);
                ps.executeUpdate();

            } else if ("update".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String courseName = request.getParameter("courseName");
                String instructor = request.getParameter("instructor");
                String schedule = request.getParameter("schedule");

                PreparedStatement ps = conn.prepareStatement(
                    "UPDATE courses SET course_name = ?, instructor = ?, schedule = ? WHERE id = ?");
                ps.setString(1, courseName);
                ps.setString(2, instructor);
                ps.setString(3, schedule);
                ps.setInt(4, id);
                ps.executeUpdate();
            }

            response.sendRedirect("success.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Course operation failed: " + e.getMessage());
        }
    }
}