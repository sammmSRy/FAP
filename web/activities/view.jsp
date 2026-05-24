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
    byte[] currId = res.getBytes("USERID");
    String currUserEmail = res.getString("USEREMAIL"), currUser = res.getString("USERLASTNAME").toUpperCase() + ", " + res.getString("USERGIVENNAME");
    int type = res.getInt("USERTYPE");
    String appelation = "Student";
    switch (type)
    {
        case 2: appelation="Administrator"; break;
        case 1: appelation="Teacher"; break;
        case 0: default: break;
    }
    
    pstm.close();
    
    String name = "", desc = "", uppr = "", start = "", end = ""; int scor = 0; String uuid = ""; boolean status = false;
    
    if (type < 2)
    {
        pstm = con.prepareStatement("SELECT ACTIVITYID, ACTIVITYNAME, COURSENAME FROM ACTIVITIES INNER JOIN COURSES ON ACTIVITIES.ACTIVITYPARENT=COURSES.COURSEID INNER JOIN REGISTRATION ON COURSES.COURSEID = REGISTRATION.REGISTRATIONSUBJECT WHERE REGISTRATIONWORKER = ? AND ACTIVITYID = ?");
        pstm.setBytes(1, currId);
        pstm.setBytes(2, Base64.getDecoder().decode(request.getParameter("id")));
        res = pstm.executeQuery();
        boolean yes = false; while (res.next()) yes = true; pstm.close();
        if (!yes) response.sendError(403);
    }
    
    pstm = con.prepareStatement("SELECT * FROM ACTIVITIES INNER JOIN COURSES ON ACTIVITIES.ACTIVITYPARENT=COURSES.COURSEID WHERE ACTIVITYID = ?");
    pstm.setBytes(1, Base64.getDecoder().decode(request.getParameter("id")));
    res = pstm.executeQuery();
    boolean yes = false;

    while (res.next())
    {
        SimpleDateFormat tempsdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
        yes = true;
        uuid = Base64.getEncoder().encodeToString(res.getBytes("ACTIVITYID"));
        name = res.getString("ACTIVITYNAME");
        desc = res.getString("ACTIVITYDESCRIPTION");
        scor = res.getInt("ACTIVITYSCORE");
        uppr = res.getString("COURSENAME");
        status = res.getBoolean("ACTIVITYSTATUS");
        start = res.getTimestamp("ACTIVITYSTART") != null? tempsdf.format(res.getTimestamp("ACTIVITYSTART")) : null;
        end = res.getTimestamp("ACTIVITYEND") != null? tempsdf.format(res.getTimestamp("ACTIVITYEND")): null;


    if (!yes) throw new ServletException(new UsernameNotFoundException());
    }
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page session="false"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Activity page &ndash; <%= name.length() == 0? "(new)":name %> &mdash; MP2</title>
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
            <h1 id="title">Activity page</h1>
            <h2><%= name %></h2>
            <p><%= desc %></p>
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
