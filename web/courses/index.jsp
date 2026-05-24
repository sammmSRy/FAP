<%-- 
    Document   : dash
    Created on : 01-Mar-2026, 18:36:21
    Author     : Adrian
--%>
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
    
    System.out.print("Initialising class " + cx.getAttribute("ClassPath").toString());
    
    Class.forName(cx.getAttribute("ClassPath").toString());
    
    String username = cx.getAttribute("Username").toString(),
       password = cx.getAttribute("Password").toString(),
       uri = cx.getAttribute("Uri").toString();
    
    System.out.print("Retrieving things");
    
    Connection con = DriverManager.getConnection(uri, username, password); System.out.print("Connection opened");
    
    PreparedStatement pstm = con.prepareStatement("SELECT * FROM USERS WHERE USEREMAIL = ?");
    pstm.setString(1, sesh.getAttribute("username").toString()); ResultSet res = pstm.executeQuery(); res.next();
    String currUserEmail = res.getString("USEREMAIL"), currUser = res.getString("USERLASTNAME").toUpperCase() + ", " + res.getString("USERGIVENNAME");
    byte[] currId = res.getBytes("USERID");
    int type = res.getInt("USERTYPE");
    String appelation = "Student";
    switch (type)
    {
        case 2: appelation="Administrator"; break;
        case 1: appelation="Teacher"; break;
        case 0: default: break;
    }
    
    pstm.close();
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
        <aside class="column" id="left">
            <h1>Tasks</h1>
            <% if (type >= 1) { %>
            <ul>
                <% if (type == 2) { %><li><a class="tocitem2" id="mkuser" href="overview.jsp?action=new">Create new course...</a></li><% } %>
                <li><a class="tocitem2 tocitemdisabled" id="gouser" onclick="go()">Check out course...</a></li>
                <li><a class="tocitem2 tocitemdisabled" id="eduser" onclick="document.getElementById('tabulation').submit()">Edit course...</a></li>
                <li><a class="tocitem2 tocitemdisabled" id="matuser" onclick="mat()">Check out members...</a></li>
                <li><a class="tocitem2 tocitemdisabled" id="deluser" onclick="delUser()">Delete course!</a></li>
            </ul>
            <% } else { %>
            <ul>
                <li><a class="tocitem2 tocitemdisabled" id="gouser" onclick="go()">Check out course...</a></li>
            </ul>
            <% } %>
        </aside>
        <main>
            <h1 id="title">Course List</h1>
            <form id="tabulation" action="overview.jsp" method="GET">
                <input type="hidden" name="action" id="action" value="edit"/>
                <input type="hidden" name="department" id="department" value="course"/>
                <table id='systemtabulation'>
                    <tr>
                        <th></th>
                        <th>Course name</th>
                    </tr>
                    <%                        
                        System.out.println("Retrieving set");
                        ResultSet rs = null; 

                        String quer = "SELECT * FROM COURSES "+ (type < 2? "INNER JOIN REGISTRATION ON COURSES.COURSEID = REGISTRATION.REGISTRATIONSUBJECT WHERE REGISTRATIONWORKER = ?":"") +" ORDER BY COURSEID ASC";
                        PreparedStatement ps1 = con.prepareStatement(quer); if (type < 2) ps1.setBytes(1, currId);
                        rs = ps1.executeQuery();
                        
                        while (rs.next())
                        { String b6 = Base64.getEncoder().encodeToString(rs.getBytes("COURSEID"));
                    %>
                        <tr onclick="pickMe('<%= b6 %>')">
                            <td><input type="radio" name="id" value="<%= b6 %>"></td>
                            <td><%= rs.getString("COURSENAME") %></td>
                        </tr>
                    <%
                        }
                    %>
                </table>
                <% if (type < 2) { %><p style="font-size:smaller; font-style:italic">Your course not in the list? Contact your <%= type == 1? "system administrator":"teacher" %> to enrol you!</p><% } %>
                
                <input type="button" name="reportgen" id="reportgen" value="Generate report" onclick="report()"/>
            </form>
        </main>
        <%@ include file="/assets/rightbar.jsp" %>
        <%@ include file="/assets/footer.jsp" %>
        <script> 
            function updateThings()
            {
                if (document.querySelector('input[name="id"]:checked'))
                {
                    <% if (type >= 1) { %> document.getElementById("eduser").classList.remove("tocitemdisabled"); <% } %>
                    <% if (type >= 1) { %> document.getElementById("deluser").classList.remove("tocitemdisabled"); <% } %>
                    <% if (type >= 1) { %> document.getElementById("matuser").classList.remove("tocitemdisabled"); <% } %>
                    document.getElementById("gouser").classList.remove("tocitemdisabled");
                }
                else
                {
                    <% if (type >= 1) { %> document.getElementById("eduser").classList.add("tocitemdisabled"); <% } %>
                    <% if (type >= 1) { %> document.getElementById("deluser").classList.add("tocitemdisabled"); <% } %>
                    <% if (type >= 1) { %> document.getElementById("matuser").classList.add("tocitemdisabled"); <% } %>
                    document.getElementById("gouser").classList.add("tocitemdisabled");    
                }
            }

            function pickMe(where)
            {
                document.querySelector('input[name=id][value="'+where+'"]').checked = true;
                updateThings(); // don't forget to fire event
            } 
            
            function delUser() // beware the pipeline! javascript -> jakarta -> java -> jdbc
            {
                if
                (confirm("Are you sure you want to delete '"
                        + document.querySelector("input[name=id]:checked").value + "'?"
                        + "\nThis activity will be lost forever! (A long time!)"))
                {        
                    let form = document.getElementById("tabulation");
                    document.getElementById("action").value = "delete";
                    form.action = "${pageContext.request.contextPath}/clerk"; form.method = "POST";
                    form.submit();
                }
            }
            
            function go()
            {
                let id = document.querySelector('input[name=id]:checked').value;
                window.location.assign("${pageContext.request.contextPath}/activities/?id="+encodeURIComponent(id));
            }
            
            function mat()
            {
                let id = document.querySelector('input[name=id]:checked').value;
                window.location.assign("${pageContext.request.contextPath}/courses/matrix.jsp?id="+encodeURIComponent(id));
            }
            
            function report()
            {
                let form = document.getElementById("tabulation");
                form.action = "${pageContext.request.contextPath}/report"; form.method = "POST";
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