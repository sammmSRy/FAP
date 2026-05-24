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
    
    if (!adm) { response.sendError(403); return; }
    
    String name = "", desc = ""; byte[] currId = null;
    pstm = con.prepareStatement("SELECT * FROM COURSES WHERE COURSEID = ?");
    pstm.setBytes(1, Base64.getDecoder().decode(request.getParameter("id")));
    res = pstm.executeQuery();
    boolean yes = false;

    while (res.next())
    {
        yes = true;
        currId = res.getBytes("COURSEID");
        name = res.getString("COURSENAME");
        desc = res.getString("COURSEDESCRIPTION");
    }

    if (!yes) throw new ServletException(new UsernameNotFoundException());
    
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page session="false"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Course matrix &ndash; <%= name %> &mdash; MP2</title>
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
            <ul>
                <li><a class="tocitem2" id="mkuser" href="${pageContext.request.contextPath}/admin/enrol.jsp">Enrol a student...</a></li>
                <li><a class="tocitem2 tocitemdisabled" id="deluser" onclick="delUser()">Remove student!</a></li>
            </ul>
        </aside>
        <main>
            <h1 id="title">Course matrix</h1>
            <h2><%= name %></h2>
            <p><%= desc %></p>
            <form id="tabulation" action="user.jsp" method="GET">
                <input type="hidden" name="action" id="action" value="edit"/>
                <input type="hidden" name="courseid" id="courseid" value="<%=Base64.getEncoder().encodeToString(currId)%>"/>
                <input type="hidden" name="department" id="department" value="user"/>
                <table id='systemtabulation'>
                    <tr>
                        <th></th>
                        <th>Email address</th>
                        <th>Name</th>
                        <% if (type == 2) { %><th>Type</th><% } %>
                    </tr>
                    <%
                        PreparedStatement pstm1 = con.prepareStatement("SELECT * FROM USERS INNER JOIN REGISTRATION ON USERS.USERID = REGISTRATION.REGISTRATIONWORKER WHERE USERTYPE <= "+(type-1)+" AND REGISTRATIONSUBJECT = ? ORDER BY USERLASTNAME ASC");
                        pstm1.setBytes(1, currId);
                        ResultSet rs = pstm1.executeQuery();
                        while (rs.next())
                        {
                            String bs6 = Base64.getEncoder().encodeToString(rs.getBytes("USERID"));
                    %>
                        <tr onclick="pickMe('<%= bs6 %>')">
                            <td><input type="radio" name="id" value="<%= bs6 %>"></td>
                            <td><%= rs.getString("USEREMAIL") %></td>
                            <td><%= rs.getString("USERLASTNAME").toUpperCase() %>, <%= rs.getString("USERGIVENNAME") %></td>
                            <% if (type == 2) { %><td><%= rs.getInt("USERTYPE") == 1? "Teacher":"Student" %></td><% } %>
                        </tr>
                    <%
                        }
                    %>
                </table>
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
                    document.getElementById("deluser").classList.remove("tocitemdisabled");          
                }
                else
                {
                    document.getElementById("deluser").classList.add("tocitemdisabled");                    
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
                (confirm("Are you sure you want to remove '"
                        + document.querySelector("input[name=id]:checked").value + "'?"
                        + "\nThis student's history will be lost forever! (A long time!)"))
                {        
                    let form = document.getElementById("tabulation");
                    document.getElementById("action").value = "delist";
                    form.action = "${pageContext.request.contextPath}/clerk"; form.method = "POST";
                    form.submit();
                }
            }
            
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