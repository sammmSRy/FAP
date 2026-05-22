/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package test;

import java.io.IOException;
import java.nio.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.util.*;

/**
 *
 * @author Adrian
 */
public class __authdebug extends HttpServlet
{
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
        try
        {
        UUID thing = UUID.randomUUID();
        ByteBuffer buffer = ByteBuffer.allocate(16);
        buffer.putLong(thing.getMostSignificantBits());
        buffer.putLong(thing.getLeastSignificantBits());
        
        PreparedStatement pstm = con.prepareStatement("INSERT INTO USERS (USERID,USERGIVENNAME,USERLASTNAME,USEREMAIL,USERPASSWORD,USERTYPE) VALUES (?,?,?,?,?,?)");
        pstm.setBytes(1,buffer.array());
        pstm.setString(2,"Matt Adrian");
        pstm.setString(3,"Sugui");
        pstm.setString(4, "ininemsn@gmail.com");
        pstm.setString(5, AuthenticationExtras.encrypt(request.getServletContext().getInitParameter("EncryptionKey").getBytes(), "ininemsn55"));
        pstm.setInt(6, 2);
        
        pstm.executeUpdate();
        
        
        }
        catch (Exception e) { throw new ServletException(e); }
        
        response.sendRedirect("/");
    }
}
