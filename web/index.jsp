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
    else response.sendRedirect("home");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Log in &mdash; MP2</title>
        <link rel="stylesheet" href="main.css"/>
        <link rel="stylesheet" href="err.css"/>
        <style>
            html
            {
                background-color: var(--normal); background-image: url("assets/bg.png");
                background-size:cover; background-attachment: fixed; background-repeat: no-repeat; background-position: top right;
                min-height:100vh;
            }
            body
            {
                display:grid; grid-template-columns: 1fr;
                grid-template-rows: 80px auto 40px; gap: 0 .1rem;
                width: 440px; height:600px; margin:20px auto;
                background-color: white; box-shadow: 0px 0px 25px #0000007f;
            }
            a#guide, a#guide:hover, a#guide:active { display:block; float:right; margin:0; box-shadow:none; padding: 0; margin: 0}
            a#local, a#local:hover, a#local:active { display:block; float:left; margin:0; box-shadow:none; padding: 0; margin: 0}
            nav.lomenu { background:black; justify-content: flex-start; align-items:flex-start;}

            /*body { grid-template-columns:1fr; grid-template-rows: 1fr;width:100vw; height: 100vh; background:inherit; box-shadow:none; place-items:center; }*/
            main, footer { grid-column:1; }

        </style>
    </head>
    <body>
        <%@ include file="assets/minihead.jsp" %>
        <main>
            <h1>Login</h1>
            <form action="auth" method="POST">
                <label for="username">Username:</label>
                <input type="text" id="username" name="username">
                <br/>
                <label for="password">Password:</label>
                <input type="password" id="password" name="password">
                <br/> <br/>
                <input type="submit" value="Login">
            </form><!--
            <form action="makeme" method="POST">
                <input type="submit" value="Evil button!">
            </form>-->
        </main>
        <%@ include file="assets/footer.jsp" %>
    </body>
</html>
