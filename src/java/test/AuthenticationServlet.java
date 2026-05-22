/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package test;
import test.warden.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import javax.security.sasl.*;
import java.security.*;
import javax.crypto.*;
import javax.crypto.spec.*;
/**
 * The main class for the JDBC pair-up with the web server.
 * @author Adrian
 */
public class AuthenticationServlet extends HttpServlet {
    
    Connection con;
    static String dbClassPath, dbUsername, dbPassword, dbUri;
    static byte[] key;
    
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
            
            dbUsername = username; dbPassword = password; dbUri = uri;
            dbClassPath = config.getInitParameter("ClassPath");
            key = config.getServletContext().getInitParameter("EncryptionKey").getBytes();
            
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
    
    protected @Override void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        // parameters in post
        // username, password
        try
        {
            String uname =  request.getParameter("username").toLowerCase(),
                    pwod = AuthenticationExtras.encrypt(request.getServletContext().getInitParameter("EncryptionKey").getBytes(), request.getParameter("password"));
            
            int type = 0;
            //response.getWriter().println(pwod); return;

            boolean yes = false;

            if (uname.length() == 0 && pwod.length() == 0) throw new NullAuthenticationException();

            try (PreparedStatement pstm = con.prepareStatement("SELECT * FROM USERS WHERE USEREMAIL = ?");)
            {
                pstm.setString(1, uname); ResultSet res = pstm.executeQuery();
                while (res.next()) { if (res.getString("USERPASSWORD").equals(pwod)) yes = true;
                else throw new IncorrectPasswordException();
                type = res.getInt("USERTYPE");
                System.err.println(type);
                }
            }
            catch (SQLException e)
            {
                System.err.println("Error in authentication process!");
                System.err.println(e.getMessage());
            }
            if (yes)
            {
                HttpSession sesh = request.getSession(false);
                if (sesh != null)
                {
                    sesh.invalidate();
                    response.sendRedirect("err/auth_pxs.htm");
                    return;
                }

                sesh = request.getSession(true);
                ServletContext cx = getServletContext();
                cx.setAttribute("ClassPath", dbClassPath);
                cx.setAttribute("Username", dbUsername);
                cx.setAttribute("Password", dbPassword);
                cx.setAttribute("Uri", dbUri);
                sesh.setAttribute("username",uname);
                sesh.setAttribute("type", type);
                sesh.setAttribute("captcha",0);
                response.sendRedirect("captcha");
            }
            else throw new AuthenticationException();
        }
        catch (Exception e) { throw new ServletException(e); }
    }
}