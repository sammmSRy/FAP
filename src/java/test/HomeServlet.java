/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package test;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
/**
 * The main class for the logoff.
 * @author Adrian
 */
public class HomeServlet extends HttpServlet {
    protected @Override void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        try
        {
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
            int type = res.getInt("USERTYPE");
            pstm.close();
            switch (type)
            {
                case 2: response.sendRedirect("admin/"); return;
                case 1: response.sendRedirect("instructor/"); return;
                case 0: default: response.sendRedirect("student/"); return;
            }
        }
        catch (Exception e) { throw new ServletException(e); }
    }
}