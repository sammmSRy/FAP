<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Invalid Date</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
    <header>
        <h1><%= application.getInitParameter("headerTitle") %></h1>
    </header>

    <div class="container" style="text-align: center;">
        <h2 style="color: red;">Invalid Date</h2>
        <p>Please enter a valid date in <strong>yyyy-MM-dd</strong> format (e.g., 2026-05-25).</p>
        <button onclick="history.back()">Go Back</button>
    </div>

    <footer><%= application.getInitParameter("footerInfo") %></footer>
</body>
</html>