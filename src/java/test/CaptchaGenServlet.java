/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package test;

import java.util.*;
import test.warden.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.awt.*;
import java.awt.image.*;
import javax.imageio.*;
/**
 *
 * @author Adrian
 */
public class CaptchaGenServlet extends HttpServlet
{
    public static String capc;
    static String generateCaptcha(int n) {
        String chrs = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        String captcha = "";
        while (n-- > 0){
            int index = (int)(Math.random() * 62);
            captcha += chrs.charAt(index);
        }
        return captcha;
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("image/jpeg");
        // Generate and store in session
        String captchaStr = capc;

        // Visual Generation
        int width = 150;
        int height = 50;
        BufferedImage bufferedImage = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
        Graphics g = bufferedImage.getGraphics();
        
        g.setColor(new Color(230, 230, 230)); // Background
        g.fillRect(0, 0, width, height);
        g.setColor(Color.BLACK); // Text Color
        g.setFont(new Font("Arial", Font.BOLD, 22));
        g.drawString(captchaStr, 15, 35);
        g.dispose();

        ImageIO.write(bufferedImage, "jpg", response.getOutputStream());
    }
}
