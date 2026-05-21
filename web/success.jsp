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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
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

            <!-- NEW: Report generation with type and date filter -->
            <form action="ReportServlet" method="GET" target="_blank" style="margin-bottom: 20px; padding: 10px; border: 1px solid #ccc; background: #f9f9f9;">
            <label>Report Type:</label>
            <select name="type">
                <option value="all">All Users</option>
                <option value="own">My Own Record</option>
            </select><br>
            <label>From Date (optional):</label>
            <input type="date" name="fromDate"><br>
            <label>To Date (optional):</label>
            <input type="date" name="toDate"><br>
            <input type="submit" value="Download PDF" style="background-color: #27ae60;">
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
            
            <h3>Add New User (Derby)</h3>
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
                
            <hr>
            <h3>Course Management (MySQL)</h3>

            <!-- Add Course Form -->
                <form action="CourseServlet" method="POST" style="margin-bottom: 15px;">
                    <input type="hidden" name="action" value="add">
                    
                    <label>Course Name:</label>
                    <input type="text" name="courseName" required>
                    
                    <label>Instructor:</label>
                    <input type="text" name="instructor" required>
                    
                    <label>Schedule:</label>
                    <input type="text" name="schedule" required>
                    <br><br>
                    <input type="submit" value="Add Course">
                </form>

            <!-- Course Report Button -->
                <form action="CourseReportServlet" method="GET" target="_blank" style="margin-bottom: 20px;">
                    <label>From Date (optional):</label>
                    <input type="date" name="fromDate">
                    
                    <label>To Date (optional):</label>
                    <input type="date" name="toDate">
                    <input type="submit" value="Download Course Report (PDF)" style="background-color: #27ae60;">
                </form>
            
            <hr>
            <h3>All Courses (MySQL)</h3>
            <table border="1">
                <tr>
                    <th>ID</th>
                    <th>Course Name</th>
                    <th>Instructor</th>
                    <th>Schedule</th>
                    <th>Created Date</th>
                    <th>Action</th>
                </tr>
                <%
                    try {
                        // Get MySQL connection using context params (same as CourseServlet)
                        String mysqlDriver = application.getInitParameter("mysqlDriver");
                        String mysqlURL = application.getInitParameter("mysqlURL");
                        String mysqlUser = application.getInitParameter("mysqlUser");
                        String mysqlPass = application.getInitParameter("mysqlPass");

                        Class.forName(mysqlDriver);
                        Connection conn = DriverManager.getConnection(mysqlURL, mysqlUser, mysqlPass);
                        Statement stmt = conn.createStatement();
                        ResultSet rs = stmt.executeQuery("SELECT * FROM courses ORDER BY created_date DESC");

                        while (rs.next()) {
                            int id = rs.getInt("id");
                %>
                <tr>
                    <td><%= id%></td>
                    <td><%= rs.getString("course_name")%></td>
                    <td><%= rs.getString("instructor")%></td>
                    <td><%= rs.getString("schedule")%></td>
                    <td><%= rs.getDate("created_date")%></td>
                    <td>
                        <!-- Delete form -->
                        <form action="CourseServlet" method="POST" style="display:inline;">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="id" value="<%= id%>">
                            <input type="submit" value="Delete" class="btn-delete"
                                   onclick="return confirm('Delete this course?');">
                        </form>
                    </td>
                </tr>
                <%
                        }
                        conn.close();
                    } catch (Exception e) {
                        out.println("<tr><td colspan='6'>Error loading courses: " + e.getMessage() + "</td></tr>");
                    }
                %>
            </table>
            
            <hr>
<h3>Assignment Management (PostgreSQL)</h3>
<form action="AssignmentServlet" method="POST" style="margin-bottom: 15px;">
    <input type="hidden" name="action" value="add">
    <label>Title:</label>
    <input type="text" name="title" required>
    <label>Course ID:</label>
    <input type="number" name="courseId" required>
    <label>Due Date:</label>
    <input type="date" name="dueDate" required>
    <input type="submit" value="Add Assignment">
</form>

<table border="1">
    <tr><th>ID</th><th>Title</th><th>Course ID</th><th>Due Date</th><th>Action</th></tr>
    <%
        try {
            // PostgreSQL connection
            String pgDriver = application.getInitParameter("postgresDriver");
            String pgURL = application.getInitParameter("postgresURL");
            String pgUser = application.getInitParameter("postgresUser");
            String pgPass = application.getInitParameter("postgresPass");

            Class.forName(pgDriver);
            Connection pgConn = DriverManager.getConnection(pgURL, pgUser, pgPass);
            Statement pgStmt = pgConn.createStatement();
            ResultSet pgRs = pgStmt.executeQuery("SELECT * FROM assignments ORDER BY due_date");
            while (pgRs.next()) {
    %>
    <tr>
        <td><%= pgRs.getInt("id") %></td>
        <td><%= pgRs.getString("title") %></td>
        <td><%= pgRs.getInt("course_id") %></td>
        <td><%= pgRs.getDate("due_date") %></td>
        <td>
            <form action="AssignmentServlet" method="POST" style="display:inline;">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="id" value="<%= pgRs.getInt("id") %>">
                <input type="submit" value="Delete" class="btn-delete"
                       onclick="return confirm('Delete this assignment?');">
            </form>
        </td>
    </tr>
    <%
            }
            pgConn.close();
        } catch (Exception e) {
            out.println("<tr><td colspan='5'>Error: " + e.getMessage() + "</td></tr>");
        }
    %>
</table>
<!-- Assignment Report Button -->
<form action="AssignmentReportServlet" method="GET" target="_blank" style="margin-top: 10px; margin-bottom: 20px;">
    <label>From Date (optional):</label>
    <input type="date" name="fromDate">
    <label>To Date (optional):</label>
    <input type="date" name="toDate">
    <input type="submit" value="Download Assignment Report (PDF)" style="background-color: #27ae60;">
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