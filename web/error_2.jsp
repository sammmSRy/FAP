<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Authentication Error</title>
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
    <header>
        <h1><%= application.getInitParameter("headerTitle") %></h1>
    </header>

    <div class="container" style="text-align: center;">
        <div class="alert-box" style="border-left-color: orange; background-color: #fff3e0; text-align: left;">
            <h3 style="color: #e67e22;">Authentication Error (Code: 2)</h3>
            <p>The password you entered is incorrect. Please try again.</p>
        </div>
        <br>
        <a href="index.jsp"><button>Back to Login Page</button></a>
    </div>

    <footer><%= application.getInitParameter("footerInfo") %></footer>
</body>
</html>