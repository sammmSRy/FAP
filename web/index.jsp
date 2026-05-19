<%-- 
    Document   : index
    Created on : 20-Feb-2026, 07:39:43
    Author     : Adrian
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page session="false"%>
<%
    HttpSession sesh = request.getSession(false);
    if (sesh != null) if ((Integer)sesh.getAttribute("captcha")!=1) sesh.invalidate();
    else response.sendRedirect("success.jsp");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Log in &mdash; MP2</title>
        <link rel="stylesheet" type="text/css" href="style.css">
        <link rel="stylesheet" type="text/css" href="main.css">
    </head>
    <body>
        <%@ include file="assets/header.jsp" %>
        <main class="container">
            <h1>Login</h1>
            <form action="auth" method="POST" style="text-align: left;">
                <label>Username:</label>
                <input type="text" name="username">
                
                <label>Password:</label>
                <input type="password" name="password">

                <div style="text-align: center; margin-top: 10px;">
                    <input type="submit" value="Login">
                </div>
            </form>
        </main>
        <%@ include file="assets/footer.jsp" %>
    </body>
</html>
