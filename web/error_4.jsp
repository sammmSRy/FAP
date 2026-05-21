<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Page Not Found</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
    <header>
        <h1><%= application.getInitParameter("headerTitle") %></h1>
    </header>

    <div class="container" style="text-align: center;">
        <h2 style="font-size: 80px; margin: 20px 0; color: #e74c3c;">404</h2>
        <h3>Oops! Page Not Found</h3>
        <p>The page or context path you are looking for does not exist or was moved.</p>
        <br>
        <a href="index.jsp"><button>Return to Home</button></a>
    </div>

    <footer><%= application.getInitParameter("footerInfo") %></footer>
</body>
</html>