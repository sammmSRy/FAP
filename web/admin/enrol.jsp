<%-- 
    Document   : dash
    Created on : 01-Mar-2026, 18:36:21
    Author     : Adrian
--%>
<%@page import="test.*"%>
<%@page import="test.warden.*"%>
<%@page import="java.sql.*"%>
<% 
    response.setHeader("Cache-Control","no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma","no-cache"); // HTTP 1.0
    response.setDateHeader ("Expires", 0); // Proxies

    HttpSession sesh = request.getSession(false);
    if (sesh == null) { response.sendError(403); return; }
    else if ((Integer)sesh.getAttribute("captcha")!=1) 
    { sesh.invalidate(); response.sendRedirect("err/auth_cpt.htm"); return; }
    
    ServletContext cx = getServletContext();
    
    Class.forName(cx.getAttribute("ClassPath").toString());
    
    String username = cx.getAttribute("Username").toString(),
       password = cx.getAttribute("Password").toString(),
       uri = cx.getAttribute("Uri").toString();
    
    Connection con = DriverManager.getConnection(uri, username, password);
    
    PreparedStatement pstm = con.prepareStatement("SELECT * FROM USERS WHERE USEREMAIL = ?");
    pstm.setString(1, sesh.getAttribute("username").toString()); ResultSet res = pstm.executeQuery(); res.next();
    
    String currUserEmail = res.getString("USEREMAIL"), currUser = res.getString("USERLASTNAME").toUpperCase() + ", " + res.getString("USERGIVENNAME");
    int type = res.getInt("USERTYPE");
    String appelation = "Student";
    switch (type)
    {
        case 2: appelation="Administrator"; break;
        case 1: appelation="Teacher"; break;
        case 0: default: break;
    }
    
    boolean adm = type >= 1;
    pstm.close();
    
    if (!adm) response.sendError(403);
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page session="false"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Enrolment &mdash; MP2</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/main.css"/>
        <style>
            body { grid-template-columns:20% 1fr 20%;}
            main, footer { grid-column: 2; }

            #systemtabulation {
                font-family: 'Cascadia Code', Consolas, 'Courier New', monospace;
                border-collapse: collapse;
                width: 90%;
                margin-left: auto;
                margin-right: auto;
            }

            #systemtabulation td, #systemtabulation th {
                padding: 4px;
                font-family:inherit;
            }
            
            #systemtabulation tr:nth-child(even){background-color: #f2f2f2;}    
            #systemtabulation tr.floaty {background-color:navy;color:white;font-style:italic;} /* those without numbers */

            /*#systemtabulation tr:hover {background-color: #ddd;}*/

            #systemtabulation th {
                padding:0px 8px;
                text-align: left;
                background-color: black;
                color: white;
            }
        </style>
    </head>
    <body>
        <%@ include file="/assets/header.jsp" %>
        <main>
            <h1 id="title">Enrolment page</h1>
            <form action="${pageContext.request.contextPath}/clerk" method="POST" id="formy">
                <input type="hidden" name="department" value="user"/>
                <label for="id">Student ID:</label>
                <select id="id" name="id">
                    <%
                        try
                        {
                           Statement stm = con.createStatement();
                           ResultSet rs1 = stm.executeQuery("SELECT * FROM USERS WHERE USERTYPE <"+ (type == 2? "2":"1"));
                           while (rs1.next())
                           {%>
                           <option value="<%= Base64.getEncoder().encodeToString(rs1.getBytes("USERID")) %>"><%= rs1.getString("USERLASTNAME").toUpperCase() + ", " + rs1.getString("USERGIVENNAME")%></option>
                           <%}
                        }
                        catch (SQLException e) { throw new ServletException(e); }
                    %>
                </select>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label for="courseid">Course: </label>
                <select id="courseid" name="courseid">
                    <%
                        try
                        {
                           Statement stm = con.createStatement();
                           ResultSet rs1 = stm.executeQuery("SELECT * FROM COURSES");
                           while (rs1.next())
                           {%>
                            <option value="<%= Base64.getEncoder().encodeToString(rs1.getBytes("COURSEID")) %>"><%= rs1.getString("COURSENAME") %></option>
                           <%}
                        }
                        catch (SQLException e) { throw new ServletException(e); }
                    %>
                </select>
                <br/> <br/>
                <input type="hidden" id="action" name="action" value="enrol"/>
                <input type="submit" id="submitbtn" value="Update">
                &nbsp;
                <input type="button" value="Cancel" onclick="window.history.back();"/>
            </form>
        </main>
        <%@ include file="/assets/rightbar.jsp" %>
        <%@ include file="/assets/footer.jsp" %>
        <script>
            <%-- well no wonder, it's actually javaSCRIPT's job, not java --%>
            window.addEventListener("pageshow", function (event) {
                if (event.persisted) window.location.reload();   
            });
        </script>
    </body>
</html>
<% con.close(); %>
