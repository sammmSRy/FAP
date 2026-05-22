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
    
    PreparedStatement pstm = con.prepareStatement("SELECT * FROM USERS WHERE EMAIL = ?");
    pstm.setString(1, sesh.getAttribute("username").toString()); ResultSet res = pstm.executeQuery(); res.next();
    String currUser = res.getString("EMAIL");
    boolean adm = res.getString("USERROLE").toUpperCase().contains("ADMIN");
    pstm.close();
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page session="false"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Dashboard &mdash; MP2</title>
        <link rel="stylesheet" href="main.css"/>
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
        <%@ include file="assets/header.jsp" %>
        <% if (adm) { %>
        <aside class="column" id="left">
            <h1>Server tasks</h1>
            <ul>
                 <li><a class="tocitem2" id="mkuser" href="user.jsp?action=new">Create new user...</a></li>
                 <li><a class="tocitem2 tocitemdisabled" id="eduser" onclick="document.getElementById('tabulation').submit()">Edit user...</a></li>
                 <li><a class="tocitem2 tocitemdisabled" id="deluser" onclick="delUser()">Delete user!</a></li>
            </ul>
        </aside>
        <% } %>
        <main>
            <h1 id="title">Welcome!</h1>
            <% if (adm) { %>
            <h1>User account database</h1>
            <form id="tabulation" action="user.jsp" method="GET">
                <input type="hidden" name="action" id="action" value="edit"/>
                <input type="hidden" name="admin" id="admin" value="<%= adm %>"/>
                <table id='systemtabulation'>
                    <tr>
                        <th></th>
                        <th>Email address</th>
                        <th>Password</th>
                        <th>User role</th>
                    </tr>
                    <%
                        ResultSet rs = con.createStatement().executeQuery("SELECT * FROM USERS ORDER BY EMAIL ASC");
                        while (rs.next())
                        {
                    %>
                        <tr onclick="pickMe('<%= rs.getString("EMAIL") %>')">
                            <td><input type="radio" name="email" value="<%= rs.getString("EMAIL") %>"></td>
                            <td><%= rs.getString("EMAIL") %></td>
                            <td>
                                <span class="realpass" style="display:none"><%= rs.getString("PASSWORD") %></span>
                                <span class="hashpass" style="display:inline"><%= new String(new char[rs.getString("PASSWORD").length()]).replace("\0","*")%></span>
                            </td>
                            <td><%= rs.getString("USERROLE") %></td>
                        </tr>
                    <%
                        }
                    %>
                </table>
                <input type="checkbox" name="showps" id="showps" class="button" onclick="notifypass()">
                <label for="showps" style="width:max-content">Show/hide passwords</label>
                <input type="button" name="reportgen" id="reportgen" value="Generate report" onclick="report()"/>
            </form>

            <% } else { %> <%-- where's my jstl!! --%>
            <form id="tabulation" action="user.jsp" method="GET">
                <input type="button" name="reportgen" id="reportgen" value="Generate ID card" onclick="report()"/>
            </form>
            <% } %>
        </main>
        <aside class="column" id="right">
            <h1>User account information</h1>
            <ul>
                <li><p class="tocitem1"><%= currUser %></p></li>
                <li><p class="tocitem2"><%= adm? "ADMINISTRATOR":"GUEST" %></p></li>
            </ul>
        </aside>
        <%@ include file="assets/footer.jsp" %>
        <script> 
            function updateThings()
            {
                if (document.querySelector('input[name="email"]:checked'))
                {
                    document.getElementById("eduser").classList.remove("tocitemdisabled");
                    if (document.querySelector('input[name="email"]:checked').value !== "<%= currUser %>")
                        document.getElementById("deluser").classList.remove("tocitemdisabled");
                    else document.getElementById("deluser").classList.add("tocitemdisabled");        
                        
                }
                else
                {
                    document.getElementById("eduser").classList.add("tocitemdisabled");
                    document.getElementById("deluser").classList.add("tocitemdisabled");                    
                }
            }
            
            function notifypass()
            {
                var el1 = document.getElementsByClassName("realpass"),
                    el2 = document.getElementsByClassName("hashpass");
                if(document.getElementById("showps").checked)
                {
                    for (var i = 0; i < el1.length; i++)
                    { el1[i].style = "display:inline"; el2[i].style = "display:none"; }
                }
                else
                {
                    for (var i = 0; i < el1.length; i++)
                    { el1[i].style = "display:none"; el2[i].style = "display:inline"; }
                }
            }

            function pickMe(where)
            {
                document.querySelector('input[name=email][value="'+where+'"]').checked = true;
                updateThings(); // don't forget to fire event
            } 
            
            function delUser() // beware the pipeline! javascript -> jakarta -> java -> jdbc
            {
                if
                (confirm("Are you sure you want to delete '"
                        + document.querySelector("input[name=email]:checked").value + "'?"
                        + "\nThis user will be lost forever! (A long time!)"))
                {        
                    let form = document.getElementById("tabulation");
                    document.getElementById("action").value = "delete";
                    document.querySelectorAll("input[name=email]").forEach(x => { x.name="username"; });
                    form.action = "clerk"; form.method = "POST";
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