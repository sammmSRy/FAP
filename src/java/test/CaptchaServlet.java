package test;

// Java pprogram to automatically generate CAPTCHA and
// verify user
import java.util.*;
import test.warden.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

public class CaptchaServlet extends HttpServlet
{
    private int len; private String cc;
    
    public void init(ServletConfig config) throws ServletException
    {
        super.init(config);
        len = Integer.parseInt(config.getInitParameter("CaptchaLen"));
    }
        
    protected @Override void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        PrintWriter out = response.getWriter();
        
        HttpSession sesh = request.getSession(false); 
        if (sesh == null || (int)sesh.getAttribute("captcha") == 1)
        { response.sendError(403); return; }// not supposed to be here if inactive or already done

        if ((int)sesh.getAttribute("captcha") == 0) sesh.setAttribute("captcha",-1); // one does not simply refresh
        else if ((int)sesh.getAttribute("captcha") == -1)
        {
            if (sesh != null) sesh.invalidate();
            response.sendRedirect("err/auth_cpt.htm");
            return;
        }
        
        cc = generateCaptcha(len);
        CaptchaGenServlet.capc = cc;
        
        // we're doin it live!!
        out.println("<html>");
        out.println("<head>");
        out.println("<title>Enter CAPTCHA to continue</title>");
        out.println("<link rel=\"stylesheet\" href=\"main.css\"/>");
        out.println("</head>");
        out.println("<body style=\"padding:1rem\"><main>");
        out.println("<img src=\"captcha/gen\" style=\"border: 1px solid #ccc; border-radius: 4px;\">");
        out.println("<p><em>Enter the string of characters as shown above.</em></p>");
        out.println("<form action=\"captcha\" method=\"POST\" style=\"margin:0\">");
        out.println("<label for=\"captchatest\">Answer:</label>");
        out.println("<input type=\"text\" id=\"captchatest\" name=\"captchatest\">");
        out.println("<br/> <br/>");
        out.println("<input type=\"submit\" value=\"Submit\">");
        out.println("</form>");
        out.println("<p>");
        out.println("This form helps protect against automated responses.");
        out.println("</p>");
        out.println("</main></body>");
        out.println("</html>");        
    }
    
    protected @Override void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        String captchatest = request.getParameter("captchatest");
        HttpSession sesh = request.getSession(false);
        if (checkCaptcha(cc,captchatest))
        {
            sesh.setAttribute("captcha",1);
            response.sendRedirect("home");
        }
        else
        {
            if (sesh != null) sesh.invalidate();
            response.sendRedirect("err/auth_cpt.htm");
            return;
        }
    }
        
    /* mr. decamora's treasures */
    
    // Returns true if given two strings are same
    static boolean checkCaptcha(String captcha, String user_captcha)
    {
            return captcha.equals(user_captcha);
    }

    // Generates a CAPTCHA of given length
    static String generateCaptcha(int n)
    {
            //to generate random integers in the range [0-61]
            Random rand = new Random(62); 

            // Characters to be included
            String chrs = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

            // Generate n characters from above set and
            // add these characters to captcha.
            String captcha = "";
            while (n-- > 0){
                    int index = (int)(Math.random()*62);
                    captcha+=chrs.charAt(index);
            }

            return captcha;
    }
}


