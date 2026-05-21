<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Login Page</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" type="text/css" href="style.css">
    </head>
    <body>
        <header>
            <h1><%= application.getInitParameter("headerTitle") %></h1>
        </header>

        <div class="container" style="max-width: 400px; text-align: center;">
            <h2>User Login</h2>
            
            <form action="LoginServlet" method="POST" style="text-align: left;">
                <label>Username:</label>
                <input type="text" name="username">
                
                <label>Password:</label>
                <input type="password" name="password">

                <div style="text-align: center; margin: 15px 0;">
                    <img src="CaptchaServlet" alt="CAPTCHA Image" style="border: 1px solid #ccc; border-radius: 4px;"><br>
                </div>
                <label>Enter Captcha:</label>
                <input type="text" name="user_captcha" required>
                
                <div style="text-align: center; margin-top: 10px;">
                    <input type="submit" value="Login">
                </div>
            </form>
        </div>

        <footer>
            <p><%= application.getInitParameter("footerInfo") %></p>
        </footer>
    </body>
</html>