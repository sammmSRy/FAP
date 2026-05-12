<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Incomplete Form</title>
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
    <header>
        <h1><%= application.getInitParameter("headerTitle") %></h1>
    </header>

    <div class="container" style="text-align: center;">
        <div class="alert-box" style="border-left-color: #f1c40f; background-color: #fef9e7; text-align: left;">
            <h3 style="color: #d4ac0d;">Incomplete Form</h3>
            <p>You must enter both a username and a password to proceed. Do not leave the fields empty.</p>
        </div>
        <br>
        <a href="index.jsp"><button>Go Back</button></a>
    </div>

    <footer><%= application.getInitParameter("footerInfo") %></footer>
</body>
</html>