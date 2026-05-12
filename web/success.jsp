<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // caching prevention
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String user = (String) session.getAttribute("user");
    String role = (String) session.getAttribute("role");

    if (user == null) {
        response.sendRedirect("error_session.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Success Page</title>
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
    <header>
        <h1><%= application.getInitParameter("headerTitle") %></h1>
    </header>

    <div class="container">
        <h2>Welcome, <%= user %>! You are logged in as: <%= role.toUpperCase() %></h2>
        <hr>

        <% if (role.equals("admin")) { %>
            <h3>Admin Panel: All Records</h3>
            <form action="ReportServlet" method="GET" target="_blank" style="margin-bottom: 10px;">
            <button type="submit" style="background-color: #27ae60;">Generate Admin Report (PDF)</button>
            </form>
            <table>
                <tr>
                    <th>Username</th>
                    <th>Password</th>
                    <th>Role</th>
                    <th>Action</th>
                </tr>
                <%
                    try {
                        Class.forName("org.apache.derby.jdbc.ClientDriver");
                        Connection conn = DriverManager.getConnection("jdbc:derby://localhost:1527/LoginDB", "app", "app");
                        Statement stmt = conn.createStatement();
                        ResultSet rs = stmt.executeQuery("SELECT * FROM USERS");

                        while (rs.next()) {
                            String dbUser = rs.getString("username");
                %>
                <tr>
                    <td><%= dbUser %></td>
                    <td><%= rs.getString("password") %></td>
                    <td><%= rs.getString("role") %></td>
                    <td>
                        <% if (!dbUser.equals(user)) { %>
                            <form action="editUser.jsp" method="POST" style="display:inline;">
                                <input type="hidden" name="targetUser" value="<%= dbUser %>">
                                <input type="hidden" name="targetPass" value="<%= rs.getString("password") %>">
                                <input type="hidden" name="targetRole" value="<%= rs.getString("role") %>">
                                <input type="submit" value="Edit" class="btn-edit">
                            </form>

                            <form action="AdminServlet" method="POST" style="display:inline;">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="targetUser" value="<%= dbUser %>">
                                <input type="submit" value="Delete" class="btn-delete" onclick="return confirm('Are you sure you want to delete <%= dbUser %>?');">
                            </form>
                        <% } else { %>
                            <i>Current User</i>
                        <% } %>
                    </td>
                </tr>
                <%
                        } 
                        conn.close();
                    } catch (Exception e) {
                        out.println("<tr><td colspan='4'>Error loading table: " + e.getMessage() + "</td></tr>");
                    }
                %>
            </table>

            <hr>
            
            <h3>Add New User</h3>
            <div style="max-width: 400px;">
                <form action="AdminServlet" method="POST">
                    <input type="hidden" name="action" value="insert">
                    
                    <label>Username:</label>
                    <input type="text" name="targetUser" required>
                    
                    <label>Password:</label>
                    <input type="password" name="targetPass" required>
                    
                    <label>Role:</label>
                    <select name="targetRole">
                        <option value="guest">Guest</option>
                        <option value="admin">Admin</option>
                    </select>
                    
                    <input type="submit" value="Create User">
                </form>
            </div>
        <% } else { %>
            <h3>Guest Panel</h3>
            <form action="ReportServlet" method="GET" target="_blank" style="margin-bottom: 10px;">
            <button type="submit" style="background-color: #27ae60;">Generate Guest Report (PDF)</button>
            </form>
            <p><strong>Username:</strong> <%= user %></p>
            <p><strong>Role:</strong> <%= role %></p>
            <p><i>As a guest, you can only view your own profile information.</i></p>
        <% } %>

        <br><br>
        <form action="logout.jsp" method="post">
            <input type="submit" value="Logout" class="btn-delete">
        </form>
    </div>
    
    <footer><%= application.getInitParameter("footerInfo") %></footer>
</body>
</html>