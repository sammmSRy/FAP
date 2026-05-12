<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // destroy session, user not logged in anymore
    session.invalidate();
    
    // redirect to login 
    response.sendRedirect("index.jsp");
%>