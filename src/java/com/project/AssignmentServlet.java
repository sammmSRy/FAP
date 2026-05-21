package com.project;

import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class AssignmentServlet extends HttpServlet {

    // PostgreSQL connection
    private Connection getConnection() throws Exception {
        ServletContext ctx = getServletContext();
        String driver = ctx.getInitParameter("postgresDriver");
        String url = ctx.getInitParameter("postgresURL");
        String user = ctx.getInitParameter("postgresUser");
        String pass = ctx.getInitParameter("postgresPass");

        Class.forName(driver);
        return DriverManager.getConnection(url, user, pass);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("error_session.jsp");
            return;
        }

        String action = request.getParameter("action");

        try (Connection conn = getConnection()) {
            if ("add".equals(action)) {
                String title = request.getParameter("title");
                int courseId = Integer.parseInt(request.getParameter("courseId"));
                String dueDate = request.getParameter("dueDate"); // yyyy-MM-dd

                PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO assignments (title, course_id, due_date) VALUES (?, ?, ?)");
                ps.setString(1, title);
                ps.setInt(2, courseId);
                ps.setDate(3, java.sql.Date.valueOf(dueDate));
                ps.executeUpdate();

            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                PreparedStatement ps = conn.prepareStatement("DELETE FROM assignments WHERE id = ?");
                ps.setInt(1, id);
                ps.executeUpdate();

            } else if ("update".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String title = request.getParameter("title");
                int courseId = Integer.parseInt(request.getParameter("courseId"));
                String dueDate = request.getParameter("dueDate");

                PreparedStatement ps = conn.prepareStatement(
                    "UPDATE assignments SET title = ?, course_id = ?, due_date = ? WHERE id = ?");
                ps.setString(1, title);
                ps.setInt(2, courseId);
                ps.setDate(3, java.sql.Date.valueOf(dueDate));
                ps.setInt(4, id);
                ps.executeUpdate();
            }

            response.sendRedirect("success.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Assignment operation failed: " + e.getMessage());
        }
    }
}