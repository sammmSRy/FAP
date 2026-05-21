<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // secu check: logged-in admins can only see this page
    String user = (String) session.getAttribute("user");
    String role = (String) session.getAttribute("role");
    
    if (user == null || !"admin".equals(role)) {
        response.sendRedirect("error_session.jsp");
        return;
    }

    // grab data from the edit button 
    String targetUser = request.getParameter("targetUser");
    String targetPass = request.getParameter("targetPass");
    String targetRole = request.getParameter("targetRole");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Edit User</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" type="text/css" href="style.css">
    <style>
        body { font-family: sans-serif; padding: 20px; }
        .edit-box { border: 1px solid #ccc; padding: 20px; width: 300px; background: #f9f9f9; }
    </style>
</head>
<body>
    <h1><%= application.getInitParameter("headerTitle") %></h1>
    
    <h2>Edit User: <%= targetUser %></h2>
    
    <div class="edit-box">
        <form action="AdminServlet" method="POST">
            <input type="hidden" name="action" value="update">
            
            <input type="hidden" name="targetUser" value="<%= targetUser %>">
            
            <label>Username:</label>
            <input type="text" value="<%= targetUser %>" disabled> <br><br>
            
            <label>Password:</label>
            <input type="text" name="targetPass" value="<%= targetPass %>" required> <br><br>
            
            <label>Role:</label>
            <select name="targetRole">
                <option value="guest" <%= "guest".equals(targetRole) ? "selected" : "" %>>Guest</option>
                <option value="admin" <%= "admin".equals(targetRole) ? "selected" : "" %>>Admin</option>
            </select> <br><br>
            
            <input type="submit" value="Save Changes">
            <a href="success.jsp" style="margin-left: 10px;">Cancel</a>
        </form>
    </div>

    <br>
    <footer><%= application.getInitParameter("footerInfo") %></footer>
</body>
</html>