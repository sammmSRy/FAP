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
    
    String currUser = res.getString("USEREMAIL");
    String appelation = "Student";
    switch (res.getInt("USERTYPE"))
    {
        case 2: appelation="Administrator"; break;
        case 1: appelation="Teacher"; break;
        case 0: default: break;
    }
    
    boolean adm = appelation.equals("Administrator");
    pstm.close();
    
    if (!adm) response.sendError(403);
    String mail = "", fname = "", lname = "", pwod = ""; int type = 0; String uuid = "";
    
    if (request.getParameter("action").equals("edit"))
    {
        pstm = con.prepareStatement("SELECT * FROM USERS WHERE USEREMAIL = ?");
        pstm.setString(1, request.getParameter("email"));
        res = pstm.executeQuery();
        boolean yes = false;
        
        while (res.next())
        {
            yes = true;
            uuid = Base64.getEncoder().encodeToString(res.getBytes("USERID"));
            mail = res.getString("USEREMAIL");
            fname = res.getString("USERGIVENNAME");
            lname = res.getString("USERLASTNAME");
            pwod = test.AuthenticationExtras.decrypt(getServletContext().getInitParameter("EncryptionKey").getBytes(), res.getString("USERPASSWORD"));
            type = res.getInt("USERTYPE");
        }
        
        if (!yes) throw new ServletException(new UsernameNotFoundException());
    }
    else uuid = Base64.getEncoder().encodeToString(ClerkExtras.uuidEncoding(UUID.randomUUID()));
    
System.out.println(currUser + " " + mail + ": " + currUser.equals(mail));
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page session="false"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>User account information page &ndash; <%= mail.length() == 0? "(new)":ClerkExtras.abbr(fname) + " " + lname %> &mdash; MP2</title>
        <link rel="stylesheet" href="main.css"/>
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
        <%@ include file="assets/header.jsp" %>
        <main>
            <h1 id="title">User account information page</h1>
            <form action="clerk" method="POST" id="formy">
                <input type="hidden" name="uuid" value="<%= uuid %>"/>
                <label for="username">Email address:</label>
                <input type="text" id="username" name="email" value="<%= mail %>" required/>
                <br/>
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" value="<%= pwod %>"/>
                <br/>
                <label for="givenname">Given name:</label>
                <input type="text" id="givenname" name="givenname" value="<%= fname %>"/>
                <br/>
                <label for="surname">Last name:</label>
                <input type="text" id="surname" name="surname" value="<%= lname %>" required/>
                <br/>
                <label for="userrole">User type:</label>
                <input type="range" id="userrole" name="userrole" value="<%= type %>" min="0" max="2" required/>
                <p>0 = student; 1 = teacher; 2 = administrator;</p>
                <br/> <br/>
                <input type="hidden" id="action" name="action" value="<%= request.getParameter("action") %>"/>
                <input type="submit" id="submitbtn" value="Update">
                &nbsp;
                <input type="button" value="Cancel" onclick="window.history.back();"/>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="button" value="Delete" onclick="delUser();" <%= currUser.equals(mail)? "disabled":"" %> <%= request.getParameter("action").equals("new")? "disabled":"" %>/>
            </form>
        </main>
        <aside class="column" id="right"> </aside>
        <%@ include file="assets/footer.jsp" %>
        <script>
            var initAdmin = document.getElementById("userrole").value;
            
            document.getElementById("formy").addEventListener("submit", postEvents);
            
            function postEvents(event)
            {
                let currAdmin = document.getElementById("userrole").value;
                if (initAdmin != currAdmin
                        && !confirm(initAdmin>currAdmin?
                "This user will lose some privileges if you continue."
                :"This user will gain some privileges if you continue."))
                    event.preventDefault();
            }
            
            function delUser()
            {
                if
                (confirm("Are you sure you want to delete '"
                        + document.getElementById("givenname").value + " " + document.getElementById("surname").value + "'?"
                        + "\nThis user will be lost forever! (A long time!)"))
                {        
                    let form = document.getElementById("formy");
                    form.removeEventListener("submit", adminConsider);
                    document.getElementById("action").value = "delete";
                    form.submit();
                }
            }
            
            <%-- well no wonder, it's actually javaSCRIPT's job, not java --%>
            window.addEventListener("pageshow", function (event) {
                if (event.persisted) window.location.reload();   
            });
        </script>
    </body>
</html>
<% con.close(); %>
