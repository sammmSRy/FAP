<%-- 
    Document   : dash
    Created on : 01-Mar-2026, 18:36:21
    Author     : Adrian
--%>
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
    
    System.out.print("Initialising class " + cx.getAttribute("ClassPath").toString());
    
    Class.forName(cx.getAttribute("ClassPath").toString());
    
    String username = cx.getAttribute("Username").toString(),
       password = cx.getAttribute("Password").toString(),
       uri = cx.getAttribute("Uri").toString();
    
    System.out.print("Retrieving things");
    
    Connection con = DriverManager.getConnection(uri, username, password); System.out.print("Connection opened");
    
    PreparedStatement pstm = con.prepareStatement("SELECT * FROM USERS WHERE USEREMAIL = ?");
    pstm.setString(1, sesh.getAttribute("username").toString()); ResultSet res = pstm.executeQuery(); res.next();
    String currUser = res.getString("USEREMAIL");
    int type = res.getInt("USERTYPE");
    String appelation = "Student";
    switch (type)
    {
        case 2: appelation="Administrator"; break;
        case 1: appelation="Teacher"; break;
        case 0: default: break;
    }
    
    boolean adm = type == 1;
    pstm.close();
    
    if (!adm) { response.sendError(403); return; }
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page session="false"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Dashboard &mdash; MP2</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/main.css"/>
        <style>
            body { grid-template-columns:20% 1fr 20%;}
            main, footer { grid-column: 2; }

            #systemtabulation {
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
            <h1 id="title">Welcome!</h1>
            <h2>Select an action</h2>
            <div style="text-align:center;vertical-align:top;">
                <button onclick="location.href='students.jsp'" style="font-size:1.25rem; padding:20px;width:300px;height:300px; margin:10px;">
                    <img src="${pageContext.request.contextPath}/assets/write.png" style="width:200px;margin:8px;">
                    <br>My Students
                </button>
                <button onclick="location.href='courses'" style="font-size:1.25rem; padding:20px;width:300px;height:300px; margin:10px;">
                    <img src="${pageContext.request.contextPath}/assets/write.png" style="width:200px;margin:8px;">
                    <br>My Courses
                </button>
            </div>
        </main>
        <aside class="column" id="right">
            <h1>User account information</h1>
            <ul>
                <li><p class="tocitem1"><%= currUser %></p></li>
                <li><p class="tocitem2"><%= appelation %></p></li>
            </ul>
        </aside>
        <%@ include file="/assets/footer.jsp" %>
        <script> 
            function report()
            {
                let form = document.getElementById("tabulation");
                form.action = "report"; form.method = "POST";
                form.submit(); 
            }
            
            
            <%-- well no wonder, it's actually javaSCRIPT's job, not java --%>
            window.addEventListener("pageshow", function (event) {
                if (event.persisted) window.location.reload();   
            });
        </script>
    </body>
</html>
<% con.close(); %>