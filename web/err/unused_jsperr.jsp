<%-- 
    Document   : 403
    Created on : 01-Mar-2026, 19:20:34
    Author     : Adrian
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Error &ndash; Forbidden &mdash; MP2</title>
        <link rel="stylesheet" href="main.css"/>
        <style>
            body { grid-template-columns:1fr; }
            main, footer { grid-column:1; }
        </style>
    </head>
    <body>
        <%@ include file="../header.jsp" %>
        <main>
            <div id="errormsg">
                <h2>Forbidden</h2>
                <p id="explanation">
                    You have insufficient credentials to access this page.
                </p>
                <br/>
                <a class="button" onclick="window.history.back()">Back to previous page</a>
                <a class="button" href="./">Back to home</a>
                <p id="errorcode">HTML ERROR 403</p>
            </div>
        </main>
        <%@ include file="../footer.jsp" %>
    </body>
</html>
