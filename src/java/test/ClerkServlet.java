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
import java.util.*;
/**
 * The main class for the JDBC pair-up with the web server.
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
        //1response.sendRedirect("./");
    }
    
    protected @Override void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        // parameters in post
        // username, password

        
        System.err.println(request.getParameter("uuid") == null? "fah":request.getParameter("uuid"));
        System.err.println(request.getParameter("email") == null? "fah":request.getParameter("email"));
        System.err.println(request.getParameter("password") == null? "fah":request.getParameter("password"));
        System.err.println(request.getParameter("action") == null? "fah":request.getParameter("action"));
        System.err.println(request.getParameter("givenname") == null? "fah":request.getParameter("givenname"));
        System.err.println(request.getParameter("surname") == null? "fah":request.getParameter("surname"));
        System.err.println(request.getParameter("userrole") == null? "fah":request.getParameter("userrole"));
        //return;
        
        
        try
        {
            byte[] id = Base64.getDecoder().decode(request.getParameter("uuid"));
            String email = request.getParameter("email"),
                    pwod = AuthenticationExtras.encrypt(request.getServletContext().getInitParameter("EncryptionKey").getBytes(), request.getParameter("password")),
                    action = request.getParameter("action"),
                    givenname = request.getParameter("givenname"),
                    surname = request.getParameter("surname");
            
            int type = Integer.parseInt(request.getParameter("userrole"));

            boolean yes = true;

            if (action.equals("edit"))
            {
                try
                (PreparedStatement pstm = con.prepareStatement("UPDATE USERS SET USEREMAIL = ?, USERGIVENNAME = ?, USERLASTNAME = ?, USERPASSWORD = ?, USERTYPE = ? WHERE USERID = ?");)
                {
                    pstm.setBytes(6, id);
                    pstm.setString(1, email);
                    pstm.setString(2, givenname);
                    pstm.setString(3, surname);
                    pstm.setString(4, pwod);
                    pstm.setInt(5, type);
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
                    pstm.setInt(6, type);
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
                (PreparedStatement pstm = con.prepareStatement("DELETE FROM USERS WHERE USEREMAIL = ?");)
                {
                    pstm.setString(1, email);
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
