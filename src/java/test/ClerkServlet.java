/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package test;
import test.warden.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import java.time.*;
import java.time.format.*;
import java.util.*;
/**
 * All the CRUDS end up here
 * @author Adrian
 */
public class ClerkServlet extends HttpServlet
{
    
    Connection con;
    
    public void init(ServletConfig config) throws ServletException
    {
        super.init(config);
        
        try
        {
            Class.forName(config.getInitParameter("ClassPath"));
            String username = config.getInitParameter("Username"),
                   password = config.getInitParameter("Password"),
                   uri = new StringBuffer(config.getInitParameter("Protocol"))
                             .append("://").append(config.getInitParameter("HostName"))
                             .append(":").append(config.getInitParameter("Port"))
                             .append("/University").toString();
            
            con = DriverManager.getConnection(uri, username, password);
        }
        catch (SQLException e)
        {
            throw new ServletException(e); // cute bubbles
        }
        catch (ClassNotFoundException e)
        {
            System.err.println("Failed to get database driver manager!");
            System.err.println(e.getMessage());
        }
    }
    
    protected @Override void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        String action = request.getParameter("action");
        try{
        if (action.equals("DEBUG__encryptAllPasswords")) AuthenticationExtras.DEBUG__encryptAllPasswords(con, response.getWriter(), request.getServletContext().getInitParameter("EncryptionKey").getBytes());
        }
        catch (Exception e) { throw new ServletException(e);}
        //response.sendRedirect("./");
    }
    
    protected @Override void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        int type = 0;
        try (PreparedStatement pstm2 = con.prepareStatement("SELECT * FROM USERS WHERE USEREMAIL = ?"))
        {
            pstm2.setString(1, request.getSession(false).getAttribute("username").toString());
            ResultSet res2 = pstm2.executeQuery(); res2.next();
            type = res2.getInt("USERTYPE");
        }
        catch (SQLException e)
        {
            System.err.println("Error in authentication process!");
            System.err.println(e.getMessage());
            throw new ServletException(e);
        }

        if (request.getParameter("department").equals("user"))
        {
            // parameters in post
            // username, password
            System.out.println("a: "+(request.getParameter("department") == null? "fah":request.getParameter("department")));
            System.out.println("b: "+(request.getParameter("id") == null? "fah":request.getParameter("id")));
            System.out.println("c: "+(request.getParameter("email") == null? "fah":request.getParameter("email")));
            System.out.println("d: "+(request.getParameter("password") == null? "fah":request.getParameter("password")));
            System.out.println("e: "+(request.getParameter("action") == null? "fah":request.getParameter("action")));
            System.out.println("f: "+(request.getParameter("givenname") == null? "fah":request.getParameter("givenname")));
            System.out.println("g: "+(request.getParameter("surname") == null? "fah":request.getParameter("surname")));
            System.out.println("h: "+(request.getParameter("userrole") == null? "fah":request.getParameter("userrole")));
            System.out.println("i: "+(request.getParameter("courseid") == null? "fah":request.getParameter("courseid")));
            //return;

            try
            {
                byte[] id = Base64.getDecoder().decode(request.getParameter("id"));
                
                String action = request.getParameter("action");

                boolean yes = false;

                if (action.equals("enrol"))
                {
                    byte[] courseid = Base64.getDecoder().decode(request.getParameter("courseid"));
                    try
                    {
                        PreparedStatement pstm = con.prepareStatement("SELECT * FROM REGISTRATION WHERE REGISTRATIONSUBJECT = ? AND REGISTRATIONWORKER = ?");
                        boolean px=false;
                        pstm.setBytes(2, id); pstm.setBytes(1, courseid);
                        
                        ResultSet res = pstm.executeQuery();
                        while (res.next()) px = true;

                        if (px) throw new ServletException(new UsernameFoundException());
                        else
                        {
                            pstm = con.prepareStatement("INSERT INTO REGISTRATION (REGISTRATIONID, REGISTRATIONSUBJECT, REGISTRATIONWORKER) VALUES (?, ?, ?)");
                            pstm.setBytes(1, ClerkExtras.uuidEncoding(UUID.randomUUID()));
                            pstm.setBytes(2, courseid);
                            pstm.setBytes(3, id);
                            yes = pstm.executeUpdate() != 0;

                            System.err.print(px);
                        }
                        pstm.close();
                    }
                    catch (SQLException e)
                    {
                        System.err.println("Error in authentication process!");
                        System.err.println(e.getMessage());
                        throw new ServletException(e);
                    }
                }
                else if (action.equals("delist"))
                {
                    byte[] courseid = Base64.getDecoder().decode(request.getParameter("courseid"));
                    try
                    (PreparedStatement pstm = con.prepareStatement("DELETE FROM REGISTRATION WHERE REGISTRATIONSUBJECT = ? AND REGISTRATIONWORKER = ?");)
                    {
                        pstm.setBytes(1, courseid);
                        pstm.setBytes(2, id);
                        yes = pstm.executeUpdate() != 0;
                        System.err.print(yes);
                    }
                    catch (SQLException e)
                    {
                        System.err.println("Error in authentication process!");
                        System.err.println(e.getMessage());
                        throw new ServletException(e);
                    }
                }
                else
                {
                    if (action.equals("edit"))
                    {
                        String email = request.getParameter("email"),
                        pwod = AuthenticationExtras.encrypt(request.getServletContext().getInitParameter("EncryptionKey").getBytes(), request.getParameter("password")),
                        givenname = request.getParameter("givenname"),
                        surname = request.getParameter("surname");
                        int type1 = Integer.parseInt(request.getParameter("userrole")); 
                        
                        try
                        (PreparedStatement pstm = con.prepareStatement("UPDATE USERS SET USEREMAIL = ?, USERGIVENNAME = ?, USERLASTNAME = ?, USERPASSWORD = ?, USERTYPE = ? WHERE USERID = ?");)
                        {
                            pstm.setBytes(6, id);
                            pstm.setString(1, email);
                            pstm.setString(2, givenname);
                            pstm.setString(3, surname);
                            pstm.setString(4, pwod);
                            pstm.setInt(5, type1);
                            yes = pstm.executeUpdate() != 0;
                            System.err.print(yes);
                        }
                        catch (SQLException e)
                        {
                            System.err.println("Error in authentication process!");
                            System.err.println(e.getMessage());
                            throw new ServletException(e);
                        }
                    }
                    else if (action.equals("new"))
                    {
                        String email = request.getParameter("email"),
                        pwod = AuthenticationExtras.encrypt(request.getServletContext().getInitParameter("EncryptionKey").getBytes(), request.getParameter("password")),
                        givenname = request.getParameter("givenname"),
                        surname = request.getParameter("surname");
                        int type1 = Integer.parseInt(request.getParameter("userrole"));
                        
                        try
                        {
                            PreparedStatement pstm = con.prepareStatement("SELECT * FROM USERS WHERE USEREMAIL = ?");

                            boolean px=false;
                            pstm.setString(1, email); ResultSet res = pstm.executeQuery();
                            while (res.next()) px = true;

                            if (px) throw new ServletException(new UsernameFoundException());

                            pstm = con.prepareStatement("INSERT INTO USERS (USERID, USEREMAIL, USERGIVENNAME, USERLASTNAME, USERPASSWORD, USERTYPE) VALUES (?, ?, ?, ?, ?, ?)");
                            pstm.setBytes(1, id);
                            pstm.setString(2, email);
                            pstm.setString(3, givenname);
                            pstm.setString(4, surname);
                            pstm.setString(5, pwod);
                            pstm.setInt(6, type1);
                            yes = pstm.executeUpdate() != 0;

                            System.err.print(yes);

                            pstm.close();
                        }
                        catch (SQLException e)
                        {
                            System.err.println("Error in authentication process!");
                            System.err.println(e.getMessage());
                            throw new ServletException(e);
                        }
                    }
                    else if (action.equals("delete"))
                    {
                        try
                        (PreparedStatement pstm = con.prepareStatement("DELETE FROM USERS WHERE USERID = ?");)
                        {
                            pstm.setBytes(1, id);
                            yes = pstm.executeUpdate() != 0;
                            System.err.print(yes);
                        }
                        catch (SQLException e)
                        {
                            System.err.println("Error in authentication process!");
                            System.err.println(e.getMessage());
                            throw new ServletException(e);
                        }
                    }
                    
                }
                if (!yes) response.sendError(400);
                    response.sendRedirect("./");
            }
            catch (ServletException f) { throw f; } // hot-potato the SQLException
            catch (Exception e) { throw new ServletException(e); } // comes from decrypt
        }
        else if (request.getParameter("department").equals("activity"))
        {
            // parameters in post
            // username, password
            System.out.println("a: "+(request.getParameter("department") == null? "fah":request.getParameter("department")));
            System.out.println("b: "+(request.getParameter("id") == null? "fah":request.getParameter("id")));
            System.out.println("c: "+(request.getParameter("name") == null? "fah":request.getParameter("name")));
            System.out.println("d: "+(request.getParameter("description") == null? "fah":request.getParameter("description")));
            System.out.println("e: "+(request.getParameter("action") == null? "fah":request.getParameter("action")));
            System.out.println("f: "+(request.getParameter("coursename") == null? "fah":request.getParameter("coursename")));
            System.out.println("g: "+(request.getParameter("startdate").isEmpty()? "fah":request.getParameter("startdate")));
            System.out.println("h: "+(request.getParameter("enddate").isEmpty()? "fah":request.getParameter("enddate")));
            System.out.println("i: "+(request.getParameter("score") == null? "fah":request.getParameter("score")));
            System.out.println("j: "+(request.getParameter("status") == null? "false":"true"));
            //return;
        
            try
            {
                byte[] id = Base64.getDecoder().decode(request.getParameter("id"));
                String name = request.getParameter("name"),
                        action = request.getParameter("action"),
                        desc = request.getParameter("description"),
                        parent = request.getParameter("coursename");
                Timestamp start = !request.getParameter("startdate").isEmpty()? Timestamp.valueOf(LocalDateTime.parse(request.getParameter("startdate"), DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"))) : null,
                        end = !request.getParameter("enddate").isEmpty()? Timestamp.valueOf(LocalDateTime.parse(request.getParameter("enddate"), DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"))) : null;
                int scor = Integer.parseInt(request.getParameter("score"));
                boolean status = request.getParameter("status") != null;

                boolean yes = false;
                byte[] cors = null;
                
                // confirm existence of course first before anything
                try (PreparedStatement pstm = con.prepareStatement("SELECT * FROM COURSES WHERE COURSENAME = ?"))
                {
                    pstm.setString(1, parent);
                    ResultSet rs = pstm.executeQuery();
                    boolean p = false; while (rs.next()) { p = true; cors = rs.getBytes("COURSEID"); }
                    pstm.close();
                    System.err.println(type == 2 && !p);
                    if (!p) // create new course if admin
                    {     
                        System.out.println("hey!");
                        try (PreparedStatement pstm1 = con.prepareStatement("INSERT INTO COURSES (COURSEID, COURSENAME) VALUES (?,?)"))
                        {
                            cors = ClerkExtras.uuidEncoding(UUID.randomUUID());
                            pstm1.setBytes(1, cors);
                            pstm1.setString(2,parent);
                            pstm1.executeUpdate();
                        }
                        catch (SQLException e) { throw e; }
                    }
                    else if (type != 2) throw new ServletException(new UsernameNotFoundException());
                }
                catch (SQLException e)
                {
                    System.err.println("Error in authentication process!");
                    System.err.println(e.getMessage());
                    throw new ServletException(e);
                }

                if (action.equals("edit"))
                {
                    try(PreparedStatement pstm = con.prepareStatement("UPDATE ACTIVITIES SET ACTIVITYNAME = ?, ACTIVITYDESCRIPTION = ?, ACTIVITYSCORE = ?, ACTIVITYPARENT = ?, ACTIVITYSTATUS = ?, ACTIVITYSTART = ?, ACTIVITYEND = ? WHERE ACTIVITYID = ?");)
                    {
                        pstm.setBytes(8, id);
                        pstm.setString(1, name);
                        pstm.setString(2, desc);
                        pstm.setInt(3, scor);
                        pstm.setBytes(4, cors);
                        pstm.setBoolean(5, status);
                        pstm.setTimestamp(6, start);
                        pstm.setTimestamp(7, end);
                        yes = pstm.executeUpdate() != 0;
                        System.err.print(yes);
                    }
                    catch (SQLException e)
                    {
                        System.err.println("Error in authentication process!");
                        System.err.println(e.getMessage());
                        throw new ServletException(e);
                    }
                }
                else if (action.equals("new"))
                {
                    try
                    {
                        PreparedStatement pstm =  con.prepareStatement("INSERT INTO ACTIVITIES (ACTIVITYID, ACTIVITYNAME, ACTIVITYDESCRIPTION, ACTIVITYSCORE, ACTIVITYPARENT, ACTIVITYSTATUS, ACTIVITYSTART, ACTIVITYEND) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
                        pstm.setBytes(1, id);
                        pstm.setString(2, name);
                        pstm.setString(3, desc);
                        pstm.setInt(4, scor);
                        pstm.setBytes(5, cors);
                        pstm.setBoolean(6, status);
                        pstm.setTimestamp(7, start);
                        pstm.setTimestamp(8, end);
                        yes = pstm.executeUpdate() != 0;

                        System.err.print(yes);

                        pstm.close();
                    }
                    catch (SQLException e)
                    {
                        System.err.println("Error in authentication process!");
                        System.err.println(e.getMessage());
                        throw new ServletException(e);
                    }
                }
                else if (action.equals("delete"))
                {
                    try
                    (PreparedStatement pstm = con.prepareStatement("DELETE FROM ACTIVITIES WHERE ACTIVITYID = ?");)
                    {
                        pstm.setBytes(1, id);
                        yes = pstm.executeUpdate() != 0;
                        System.err.print(yes);
                    }
                    catch (SQLException e)
                    {
                        System.err.println("Error in authentication process!");
                        System.err.println(e.getMessage());
                        throw new ServletException(e);
                    }
                }
                if (!yes) response.sendError(400);
                response.sendRedirect("./");
            }
            catch (ServletException f) { throw f; } // hot-potato the SQLException
            catch (Exception e) { throw new ServletException(e); } // comes from decrypt
        }
        else if (request.getParameter("department").equals("course"))
        {
            // parameters in post
            // username, password
            System.out.println("a: "+(request.getParameter("department") == null? "fah":request.getParameter("department")));
            System.out.println("b: "+(request.getParameter("id") == null? "fah":request.getParameter("id")));
            System.out.println("c: "+(request.getParameter("name") == null? "fah":request.getParameter("name")));
            System.out.println("d: "+(request.getParameter("description") == null? "fah":request.getParameter("description")));
            System.out.println("e: "+(request.getParameter("action") == null? "fah":request.getParameter("action")));
            //return;
        
            try
            {
                byte[] id = Base64.getDecoder().decode(request.getParameter("id"));
                String name = request.getParameter("name"),
                        action = request.getParameter("action"),
                        desc = request.getParameter("description");

                boolean yes = false;
                byte[] cors = null;

                if (action.equals("edit"))
                {
                    try(PreparedStatement pstm = con.prepareStatement("UPDATE COURSES SET COURSENAME = ?, COURSEDESCRIPTION = ? WHERE COURSEID = ?");)
                    {
                        pstm.setBytes(3, id);
                        pstm.setString(1, name);
                        pstm.setString(2, desc);
                        yes = pstm.executeUpdate() != 0;
                        System.err.print(yes);
                    }
                    catch (SQLException e)
                    {
                        System.err.println("Error in authentication process!");
                        System.err.println(e.getMessage());
                        throw new ServletException(e);
                    }
                }
                else if (action.equals("new"))
                {
                    try
                    {
                        PreparedStatement pstm = con.prepareStatement("SELECT * FROM COURSES WHERE COURSENAME = ?");

                        boolean px=false;
                        pstm.setString(1, name); ResultSet res = pstm.executeQuery();
                        while (res.next()) px = true;

                        if (px) throw new ServletException(new UsernameFoundException());
                        
                        pstm =  con.prepareStatement("INSERT INTO COURSES (COURSEID, COURSENAME, COURSEDESCRIPTION) VALUES (?, ?, ?)");
                        pstm.setBytes(1, id);
                        pstm.setString(2, name);
                        pstm.setString(3, desc);
                        yes = pstm.executeUpdate() != 0;

                        System.err.print(yes);

                        pstm.close();
                    }
                    catch (SQLException e)
                    {
                        System.err.println("Error in authentication process!");
                        System.err.println(e.getMessage());
                        throw new ServletException(e);
                    }
                }
                else if (action.equals("delete"))
                {
                    try
                    (PreparedStatement pstm = con.prepareStatement("DELETE FROM COURSES WHERE COURSEID = ?");)
                    {
                        pstm.setBytes(1, id);
                        yes = pstm.executeUpdate() != 0;
                        System.err.print(yes);
                    }
                    catch (SQLException e)
                    {
                        System.err.println("Error in authentication process!");
                        System.err.println(e.getMessage());
                        throw new ServletException(e);
                    }
                }
                if (!yes) response.sendError(400);
                response.sendRedirect("./");
            }
            catch (ServletException f) { throw f; } // hot-potato the SQLException
            catch (Exception e) { throw new ServletException(e); } // comes from decrypt
        }
        else if (request.getParameter("department").equals("job"))
        {
            // parameters in post
            // username, password
            System.out.println("a: "+(request.getParameter("department") == null? "fah":request.getParameter("department")));
            System.out.println("b: "+(request.getParameter("jobid") == null? "fah":request.getParameter("jobid")));
            System.out.println("c: "+(request.getParameter("actid") == null? "fah":request.getParameter("actid")));
            System.out.println("d: "+(request.getParameter("userid") == null? "fah":request.getParameter("userid")));
            System.out.println("e: "+(request.getParameter("status") == null? "fah":request.getParameter("status")));
            System.out.println("f: "+(request.getParameter("score") == null? "fah":request.getParameter("score")));
            System.out.println("g: "+(request.getParameter("action") == null? "fah":request.getParameter("action")));
            //return;
        
            try
            {
                byte[] jobid = Base64.getDecoder().decode(request.getParameter("jobid"));
                String action = request.getParameter("action");

                boolean yes = false;

                if (action.equals("submit"))
                {
                    try(PreparedStatement pstm = con.prepareStatement("UPDATE JOB SET JOBSTATUS = ?, JOBEND = ? WHERE JOBID = ?");)
                    {
                        pstm.setBytes(3, jobid);
                        pstm.setInt(1, 1);
                        pstm.setTimestamp(2, Timestamp.valueOf(LocalDateTime.now()));
                        yes = pstm.executeUpdate() != 0;
                        System.err.print(yes);
                    }
                    catch (SQLException e)
                    {
                        System.err.println("Error in authentication process!");
                        System.err.println(e.getMessage());
                        throw new ServletException(e);
                    }
                }
                else if (action.equals("grade"))
                {
                    int score = Integer.valueOf(request.getParameter("score"));
                    try(PreparedStatement pstm = con.prepareStatement("UPDATE JOB SET JOBSTATUS = ?, JOBSCORE = ? WHERE JOBID = ?");)
                    {
                        pstm.setBytes(3, jobid);
                        pstm.setInt(2, score);
                        pstm.setInt(1, 2);
                        yes = pstm.executeUpdate() != 0;
                        System.err.print(yes);
                    }
                    catch (SQLException e)
                    {
                        System.err.println("Error in authentication process!");
                        System.err.println(e.getMessage());
                        throw new ServletException(e);
                    }
                }
                else if (action.equals("delete"))
                {
                    try
                    (PreparedStatement pstm = con.prepareStatement("DELETE FROM JOB WHERE JOBID = ?");)
                    {
                        pstm.setBytes(1, jobid);
                        yes = pstm.executeUpdate() != 0;
                        System.err.print(yes);
                    }
                    catch (SQLException e)
                    {
                        System.err.println("Error in authentication process!");
                        System.err.println(e.getMessage());
                        throw new ServletException(e);
                    }
                }
                if (!yes) response.sendError(400);
                response.sendRedirect("./");
            }
            catch (ServletException f) { throw f; } // hot-potato the SQLException
            catch (Exception e) { throw new ServletException(e); } // comes from decrypt
        }
    }
}

