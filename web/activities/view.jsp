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
    byte[] currId = res.getBytes("USERID"), actid = Base64.getDecoder().decode(request.getParameter("id"));
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
    
    String name = "", desc = "", uppr = "", start = "", end = ""; int hps = 0, as = 0, istatus = 0; String uuid = ""; boolean status = false;
    byte[] jobid = null, parid = null;
    
    if (type < 2)
    {
        pstm = con.prepareStatement("SELECT ACTIVITYID, ACTIVITYNAME, COURSENAME FROM ACTIVITIES INNER JOIN COURSES ON ACTIVITIES.ACTIVITYPARENT=COURSES.COURSEID INNER JOIN REGISTRATION ON COURSES.COURSEID = REGISTRATION.REGISTRATIONSUBJECT WHERE REGISTRATIONWORKER = ? AND ACTIVITYID = ?");
        pstm.setBytes(1, currId);
        pstm.setBytes(2, actid);
        res = pstm.executeQuery();
        boolean yes = false; while (res.next()) yes = true; pstm.close();
        if (!yes) response.sendError(403);
    }
    
    pstm = con.prepareStatement("SELECT * FROM ACTIVITIES INNER JOIN COURSES ON ACTIVITIES.ACTIVITYPARENT=COURSES.COURSEID WHERE ACTIVITYID = ?");
    pstm.setBytes(1, actid);
    res = pstm.executeQuery();
    boolean yes = false;

    while (res.next())
    {
        SimpleDateFormat tempsdf = new SimpleDateFormat("EEEE, dd MMMM yyyy 'at' HH:mm:ss");
        yes = true;
        uuid = Base64.getEncoder().encodeToString(res.getBytes("ACTIVITYID"));
        parid = res.getBytes("ACTIVITYPARENT");
        name = res.getString("ACTIVITYNAME");
        desc = res.getString("ACTIVITYDESCRIPTION");
        uppr = res.getString("COURSENAME");
        status = res.getBoolean("ACTIVITYSTATUS");
        start = res.getTimestamp("ACTIVITYSTART") != null? tempsdf.format(res.getTimestamp("ACTIVITYSTART")) : null;
        end = res.getTimestamp("ACTIVITYEND") != null? tempsdf.format(res.getTimestamp("ACTIVITYEND")): null;

        if (!yes) throw new ServletException(new UsernameNotFoundException());
    }
    
    if (type == 0) // retrieve job
    {
        pstm = con.prepareStatement("SELECT * FROM JOB INNER JOIN USERS ON USERS.USERID = JOB.JOBWORKER INNER JOIN ACTIVITIES ON ACTIVITIES.ACTIVITYID = JOB.JOBSUBJECT WHERE USERID = ? AND ACTIVITYID = ?");
        pstm.setBytes(1, currId);
        pstm.setBytes(2, actid);
        res = pstm.executeQuery();
        boolean yes1 = false;
        while (res.next())
        {
            SimpleDateFormat tempsdf = new SimpleDateFormat("EEEE, dd MMMM yyyy 'at' HH:mm:ss");
            yes1 = true;   
            jobid = res.getBytes("JOBID");
            istatus = res.getInt("JOBSTATUS");
            hps = res.getInt("ACTIVITYSCORE");
            as = res.getInt("JOBSCORE");
            end = res.getTimestamp("JOBEND") != null? tempsdf.format(res.getTimestamp("JOBEND")):null;
        }
        if (!yes1)
        {
            byte[] newid = ClerkExtras.uuidEncoding(UUID.randomUUID());
            try
            {
                boolean yes2 = false;
                pstm = con.prepareStatement("INSERT INTO JOB (JOBID, JOBSUBJECT, JOBWORKER, JOBSTATUS) VALUES (?, ?, ?, ?)");
                pstm.setBytes(1, newid);
                pstm.setBytes(2, actid);
                pstm.setBytes(3, currId);
                pstm.setBoolean(4, false);
                yes2 = pstm.executeUpdate() != 0;
                if (!yes2) throw new ServletException();
            }
            catch (SQLException e) { throw new ServletException(e); }
            jobid = newid;
            
        }
    }
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page session="false"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Activity page &ndash; <%= name %> &mdash; MP2</title>
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
        <aside class="column" id="left">
            <h1>Tasks</h1>
            <ul>
                <% if (type >= 1) { %><li><a class="tocitem2 tocitemdisabled" id="eduser" onclick="go()">Confirm grade</a></li><% } 
                 else { %><li><a class="tocitem2 <%= istatus > 0? "tocitemdisabled":""%>" id="eduser" onclick="document.getElementById('tabulation').submit()">Turn it in!</a></li><% } %>
            </ul>
        </aside>
        <main>
            <h1 id="title">Activity page</h1>
            <h2><%= name %></h2>
            <p><%= desc %></p>
            
            <% if (type == 0) { %>
                <% if (istatus>0) { %>
                <p><em>Submitted on <%= end %></em></p>
                <%if (istatus==2) if (hps>0){ %>
                <p><em>Score:</em>&nbsp;<strong><%=as%></strong>/<%=hps%></p>
                <% } else { %>
                <p>Reckoned</p>
                <% } } %>
                <form action="${pageContext.request.contextPath}/clerk" id="tabulation" method="POST">
                    <input type="hidden" name="jobid" id="jobid" value="<%=Base64.getEncoder().encodeToString(jobid)%>"/>
                    <input type="hidden" name="actid" id="actid" value="<%=uuid%>"/>
                    <input type="hidden" name="userid" id="userid" value="<%=Base64.getEncoder().encodeToString(currId)%>"/>
                    <input type="hidden" name="status" id="status" value="<%=istatus%>"/>
                    <input type="hidden" name="action" id="action" value="submit"/>
                    <input type="hidden" name="department" id="department" value="job"/>
                </form>
            <% } else { %>
                <form id="tabulation" action="sub.jsp" method="GET">
                    <%                        
                    System.out.println("Initialised rset");
                    ResultSet rs = null;

                    System.out.println("Initialised query");
                    String quer = "SELECT * FROM USERS INNER JOIN REGISTRATION ON USERS.USERID = REGISTRATION.REGISTRATIONWORKER INNER JOIN COURSES ON REGISTRATION.REGISTRATIONSUBJECT = COURSES.COURSEID INNER JOIN ACTIVITIES ON COURSES.COURSEID = ACTIVITIES.ACTIVITYPARENT AND ACTIVITIES.ACTIVITYID = ? LEFT JOIN JOB ON USERS.USERID = JOB.JOBWORKER AND ACTIVITIES.ACTIVITYID = JOB.JOBSUBJECT WHERE USERS.USERTYPE = 0 AND COURSEID = ? ORDER BY USERLASTNAME ASC";
                    PreparedStatement pstm1 = con.prepareStatement(quer);
                    pstm1.setBytes(1, actid);pstm1.setBytes(2, parid);
                    rs = pstm1.executeQuery();
                    System.out.println("succ");
                    %>
                    <input type="hidden" name="action" id="action" value="edit"/>
                    <input type="hidden" name="department" id="department" value="job"/>
                    <input type="hidden" name="actid" id="actid" value="<%=uuid%>"/>
                    <table id='systemtabulation'>
                        <tr>
                            <th></th>
                            <th>Student name</th>
                            <th>Submission status</th>
                            <th>Score</th>
                        </tr>
                        <%
                            while (rs.next()) 
                            { hps = rs.getInt("ACTIVITYSCORE"); System.out.println(rs.getInt("JOBSTATUS"));String b6 = rs.getBytes("JOBID") != null && rs.getInt("JOBSTATUS") > 0? Base64.getEncoder().encodeToString(rs.getBytes("JOBID")) : "";
                        %>
                            <tr<% if (rs.getBytes("JOBID") != null && rs.getInt("JOBSTATUS") > 0) { %> onclick="pickMe('<%=b6%>')"<% } %>>
                                <td><% if (rs.getBytes("JOBID") != null && rs.getInt("JOBSTATUS") > 0) { %><input type="radio" name="jobid" value="<%= b6 %>"><% } %></td>
                                <td><%= rs.getString("USERLASTNAME").toUpperCase() %>, <%= rs.getString("USERGIVENNAME") %></td>
                                <td>
                                    <% if (rs.getBytes("JOBID") == null) { %>Unopened<% } 
                                       else switch (rs.getInt("JOBSTATUS")) { 
                                        case 0:%>Opened<% break;
                                        case 1:%>Submitted<% break;
                                        case 2:%>Graded<% break;
                                    }%>
                                </td>
                                <td>
                                    <input type="hidden" id="<%= b6 %>_score" value="<%=rs.getInt("JOBSCORE")%>"/>
                                    <% if (rs.getInt("ACTIVITYSCORE")>0) { %><%=rs.getInt("JOBSCORE")%>/<%=rs.getInt("ACTIVITYSCORE")%><% } 
                                      else if (rs.getInt("JOBSTATUS") < 2) { %>Ungraded<% } 
                                      else { %>&check;<% } %>
                                </td>
                            </tr>
                        <%
                            }
                        %>
                    </table>
                    <label for="score" style="width:100%">Confirm score for selected student: 
                    <input type="number" name="score" id="score" value="0" min="0" max="<%= hps %>" style="width:2rem" disabled/></label>
                    <br/><br/>
                    <input type="button" name="reportgen" id="reportgen" value="Generate report" onclick="report()"/>
                </form>
            <% } %>
        </main>
        <%@ include file="/assets/rightbar.jsp" %>
        <%@ include file="/assets/footer.jsp" %>
        <script>
            function updateThings()
            {
                if (document.querySelector('input[name="jobid"]:checked'))
                {
                    document.getElementById("eduser").classList.remove("tocitemdisabled");
                    document.getElementById("score").disabled = false;
                }
                else
                {
                    document.getElementById("eduser").classList.add("tocitemdisabled");
                    document.getElementById("score").disabled = true;
                }
            }

            function pickMe(where)
            {
                document.querySelector('input[name=jobid][value="'+where+'"]').checked = true;
                document.getElementById("score").value = document.querySelector('input[id="'+where+'_score"]').value;
                updateThings(); // don't forget to fire event
            } 
            
            function go() // beware the pipeline! javascript -> jakarta -> java -> jdbc
            {
                if
                (confirm("Confirm this grade?"))
                {        
                    let form = document.getElementById("tabulation");
                    document.getElementById("action").value = "grade";
                    form.action = "${pageContext.request.contextPath}/clerk"; form.method = "POST";
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
