<%-- 
    Document   : footer
    Created on : 01-Mar-2026, 17:44:30
    Author     : Adrian
--%>

<%@page import="java.util.*"%>
<%@page import="java.text.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<footer>
    <p>&copy; 2026 Matt Adrian Sugui. All rights reserved.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    This server's birthdate: <%= getServletContext().getAttribute("date").toString() %> </p>
    <!-- Last updated syntax: 2 January 2006 at 3.04.05 am -->
</footer>