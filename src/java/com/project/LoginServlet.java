package com.project;

import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import com.project.warden.*;

public class LoginServlet extends HttpServlet {

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
                             .append("/LoginDB").toString();
            
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
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // parameters in post
        // username, password
        try
        {
            String uname =  request.getParameter("username").toLowerCase(),
                    pwod = AuthenticationExtras.encrypt(request.getServletContext().getInitParameter("EncryptionKey").getBytes(), request.getParameter("password"));

            //response.getWriter().println(pwod); return;

            boolean yes = false;

            if (uname.length() == 0 && pwod.length() == 0) throw new NullAuthenticationException();

            try (PreparedStatement pstm = con.prepareStatement("SELECT * FROM USERS WHERE EMAIL = ?");)
            {
                pstm.setString(1, uname); ResultSet res = pstm.executeQuery();
                while (res.next()) if (res.getString("PASSWORD").equals(pwod)) yes = true;
                else throw new IncorrectPasswordException();
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
                    response.sendRedirect("error_session.jsp");
                    return;
                }

                sesh = request.getSession(true);
                ServletContext cx = getServletContext();
                cx.setAttribute("ClassPath", dbClassPath);
                cx.setAttribute("Username", dbUsername);
                cx.setAttribute("Password", dbPassword);
                cx.setAttribute("Uri", dbUri);
                sesh.setAttribute("username",uname);
                sesh.setAttribute("captcha",0);
                response.sendRedirect("captcha");
            }
            else throw new AuthenticationException();
        }
        catch (Exception e) { throw new ServletException(e); }
    }
}