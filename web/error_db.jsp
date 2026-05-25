<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Database Error</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
    <header>
        <h1><%= application.getInitParameter("headerTitle") %></h1>
    </header>

    <div class="container" style="text-align: center;">
        <h2 style="color: red;">Database Error</h2>
        <p>An unexpected database error occurred. Please try again later.</p>
        <button onclick="history.back()">Go Back</button>
    </div>

    <footer><%= application.getInitParameter("footerInfo") %></footer>
</body>
</html>