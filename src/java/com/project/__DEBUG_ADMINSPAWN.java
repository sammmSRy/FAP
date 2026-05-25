/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.project;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;

/**
 *
 * @author Adrian
 */
public class __DEBUG_ADMINSPAWN extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try { response.getWriter().println(fuck());}
        catch (Exception e) { throw new ServletException(e); }
    }
    
    public static String fuck() throws Exception {
        String plainPassword = "admin";           
        String secretKey = "MySecr3tK3y12345";          
        String algorithm = "AES";                       

        String encrypted = CryptoUtil.encrypt(plainPassword, secretKey, algorithm);
        System.out.println("Encrypted dummy password: " + encrypted);
        return encrypted;
    }
}
