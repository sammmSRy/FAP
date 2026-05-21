<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Invalid Credentials</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
    <header>
        <h1><%= application.getInitParameter("headerTitle") %></h1>
    </header>

    <div class="container" style="text-align: center;">
        <div class="alert-box" style="text-align: left;">
            <h3>Invalid Credentials (Code: 3)</h3>
            <p>The username and password provided do not match any record in our system.</p>
        </div>
        <br>
        <a href="index.jsp"><button>Try Again</button></a>
    </div>

    <footer><%= application.getInitParameter("footerInfo") %></footer>
</body>
</html>