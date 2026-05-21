<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Captcha Error</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
    <header>
        <h1><%= application.getInitParameter("headerTitle") %></h1>
    </header>

    <div class="container" style="text-align: center;">
        <div class="alert-box" style="border-left-color: #8e44ad; background-color: #f4ecf8; text-align: left;">
            <h3 style="color: #8e44ad;">Captcha Verification Failed</h3>
            <p>The CAPTCHA code you entered did not match the image. Please try again.</p>
        </div>
        <br>
        <a href="index.jsp"><button>Back to Login Page</button></a>
    </div>

    <footer><%= application.getInitParameter("footerInfo") %></footer>
</body>
</html>