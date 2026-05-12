package com.project;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.image.BufferedImage;
import java.io.IOException;
import javax.imageio.ImageIO;
import javax.servlet.ServletException;
import javax.servlet.http.*;

public class CaptchaServlet extends HttpServlet {

    
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
        
        // Fetch length from DD
        int length = Integer.parseInt(getServletContext().getInitParameter("captchaLength"));
        
        // Generate and store in session
        String captchaStr = generateCaptcha(length);
        request.getSession().setAttribute("captchaVal", captchaStr);

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