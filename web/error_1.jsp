<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Login Error</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
    <header>
        <h1><%= application.getInitParameter("headerTitle") %></h1>
    </header>

    <div class="container" style="text-align: center;">
        <div class="alert-box" style="text-align: left;">
            <h3>Login Error (Code: 1)</h3>
            <p>The username entered does not exist in our database, and you left the password field empty.</p>
        </div>
        <br>
        <a href="index.jsp"><button>Back to Login Page</button></a>
    </div>

    <footer><%= application.getInitParameter("footerInfo") %></footer>
</body>
</html>