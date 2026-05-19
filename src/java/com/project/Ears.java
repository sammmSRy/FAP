package com.project;

import java.util.*;
import java.time.*;
import java.time.format.*;
import javax.servlet.*;
import javax.servlet.annotation.WebListener;

/**
 *
 * @author Adrian
 */
public @WebListener class Ears implements ServletContextListener {
   public @Override void contextInitialized(ServletContextEvent sce) 
   {
       ServletContext con = sce.getServletContext();
       con.setAttribute("date", LocalDate.now().format(DateTimeFormatter.ofPattern("EEEE, dd MMMM yyyy")) + " at " + LocalTime.now().format(DateTimeFormatter.ofPattern("HH:mm:ss")));
       //con.setAttribute("key", "".getBytes());
   }
   public void contextDestroyed(ServletContextEvent servletContextEvent) {
    }
}