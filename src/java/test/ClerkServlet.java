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
                             .append("/LoginDB").toString();
            
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

        /*
        response.getWriter().println(request.getParameter("username") == null? "fah":request.getParameter("username"));
        response.getWriter().println(request.getParameter("password") == null? "fah":request.getParameter("password"));
        response.getWriter().println(request.getParameter("action") == null? "fah":request.getParameter("action"));
        response.getWriter().println(request.getParameter("userrole") == null? "fah":request.getParameter("userrole"));
        return;
        */
        try
        {
            String uname = request.getParameter("username_r").toLowerCase(),
                    pwod = AuthenticationExtras.encrypt(request.getServletContext().getInitParameter("EncryptionKey").getBytes(), request.getParameter("password")),
                    action = request.getParameter("action");
            boolean isAdmin = request.getParameter("userrole") != null, yes=false;



            if (action.equals("edit"))
            {
                try
                (PreparedStatement pstm = con.prepareStatement("UPDATE USERS SET PASSWORD = ?, USERROLE = ? WHERE EMAIL = ?");)
                {
                    pstm.setString(3, uname);
                    pstm.setString(1, pwod);
                    pstm.setString(2, isAdmin?"Admin":"Guest");
                    yes = pstm.executeUpdate() != 0;
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
                    PreparedStatement pstm = con.prepareStatement("SELECT * FROM USERS WHERE EMAIL = ?");

                    boolean px=false;
                    pstm.setString(1, uname); ResultSet res = pstm.executeQuery();
                    while (res.next()) px = true;

                    if (px) throw new ServletException(new UsernameFoundException());

                    pstm = con.prepareStatement("INSERT INTO USERS (EMAIL, PASSWORD, USERROLE) VALUES (?, ?, ?)");
                    pstm.setString(1, uname);
                    pstm.setString(2, pwod);
                    pstm.setString(3, isAdmin?"Admin":"Guest");
                    yes = pstm.executeUpdate() != 0;

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
                (PreparedStatement pstm = con.prepareStatement("DELETE FROM USERS WHERE EMAIL = ?");)
                {
                    pstm.setString(1, uname);
                    yes = pstm.executeUpdate() != 0;
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
        catch (Exception e) { response.sendError(400); } // comes from decrypt
    }
}
