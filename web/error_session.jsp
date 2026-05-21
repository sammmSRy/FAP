<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Unauthorized</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
    <header>
        <h1><%= application.getInitParameter("headerTitle") %></h1>
    </header>

    <div class="container" style="text-align: center;">
        <div class="alert-box" style="border-left-color: #7f8c8d; background-color: #f2f4f4; text-align: left;">
            <h3>Unauthorized Access</h3>
            <p>Your session has expired, or you attempted to access a protected page without logging in.</p>
        </div>
        <br>
        <a href="index.jsp"><button>Log In Here</button></a>
    </div>

    <footer><%= application.getInitParameter("footerInfo") %></footer>
</body>
</html>