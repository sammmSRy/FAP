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
public class ExitServlet extends HttpServlet {
    protected @Override void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        HttpSession sesh = request.getSession(false);
        if (sesh!=null) sesh.invalidate(); // if timeout occurred already then just go on
        response.sendRedirect("./");
    }
}