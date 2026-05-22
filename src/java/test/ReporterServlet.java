/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package test;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import java.util.*;
import test.warden.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.time.*;
import java.time.format.*;
import java.io.*;
import java.sql.*;
import java.time.temporal.WeekFields;

/**
 *
 * @author Adrian
 */
public class ReporterServlet extends HttpServlet
{
    Connection con;
    static String dbClassPath, dbUsername, dbPassword, dbUri, currUser, currPass;
    static boolean admin;
    
    public void init(ServletConfig config) throws ServletException
    {
        super.init(config);
        
        try
        {
            ServletContext cx = getServletContext();
    
            System.out.print("Initialising class " + cx.getAttribute("ClassPath").toString());

            Class.forName(cx.getAttribute("ClassPath").toString());

            String username = cx.getAttribute("Username").toString(),
               password = cx.getAttribute("Password").toString(),
               uri = cx.getAttribute("Uri").toString();

            System.out.print("Retrieving things");
            
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
        LocalDateTime nn = LocalDateTime.now(); admin = Boolean.parseBoolean(request.getParameter("admin"));
        
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "inline; filename=\"report_"+ nn.format(DateTimeFormatter.ofPattern("YYYYMMddHHmmss")) + ".pdf\"");
       
        HttpSession sesh = request.getSession(false);
        if (sesh == null) { response.sendError(403); return; }
        else if ((Integer)sesh.getAttribute("captcha")!=1) 
        { sesh.invalidate(); response.sendRedirect("err/auth_cpt.htm"); return; }
        
        try
        {
            PreparedStatement pstm = con.prepareStatement("SELECT * FROM USERS WHERE EMAIL = ?");
            pstm.setString(1, request.getSession(false).getAttribute("username").toString()); ResultSet res = pstm.executeQuery(); res.next();
            currUser = res.getString("EMAIL");
            currPass = test.AuthenticationExtras.decrypt(getServletContext().getInitParameter("EncryptionKey").getBytes(), res.getString("PASSWORD"));
            pstm.close();

            Document doc = null;

            if (admin) try
            {
                doc = new Document(PageSize.LETTER);
                PdfWriter a = PdfWriter.getInstance(doc, response.getOutputStream());
                a.setPageEvent(new HeaderAndFooterStamper());
                doc.addAuthor("Matt's Super Awesome Web Site!");
                doc.addCreationDate();
                doc.addSubject("User account database report");
                //doc.setMargins(2.5f,2.5f,2.5f,2.5f);

                doc.open();

                //
                // Hello, world!
                //
                Paragraph p = new Paragraph("User account database report",FontFactory.getFont(FontFactory.HELVETICA, 24f, Font.BOLD, BaseColor.BLACK));
                p.setSpacingAfter(16f);
                p.setAlignment(1);

                //p.add("");

                doc.add(p);

                PdfPTable t = new PdfPTable(2);
                PdfPCell c = new PdfPCell(), d = new PdfPCell();
                c.setBackgroundColor(BaseColor.BLACK); d.setBackgroundColor(BaseColor.BLACK);
                c.addElement(new Phrase("User email",FontFactory.getFont(FontFactory.HELVETICA, 12f, 0, BaseColor.WHITE)));
                d.addElement(new Phrase("User role",FontFactory.getFont(FontFactory.HELVETICA, 12f, 0, BaseColor.WHITE)));
                t.addCell(c); t.addCell(d);

                t.completeRow();
                ResultSet rs = con.createStatement().executeQuery("SELECT * FROM USERS ORDER BY EMAIL ASC");
                while (rs.next())
                {
                    t.addCell(new PdfPCell(new Phrase(rs.getString("EMAIL")+(currUser.equals(rs.getString("EMAIL"))?"*":""),FontFactory.getFont(FontFactory.HELVETICA, 10f, currUser.equals(rs.getString("EMAIL"))?Font.BOLD:0, BaseColor.BLACK))));
                    t.addCell(new PdfPCell(new Phrase(rs.getString("USERROLE"),FontFactory.getFont(FontFactory.HELVETICA, 10f, Font.ITALIC, BaseColor.BLACK))));
                    t.completeRow();
                }

                doc.add(t);
                doc.close();
                
            }
            catch (Exception e)
            {
                throw new ServletException(e);
            }
            else try
            {
                doc = new Document(new Rectangle(PageSize.POSTCARD.getHeight(), PageSize.POSTCARD.getWidth()));
                PdfWriter a = PdfWriter.getInstance(doc, response.getOutputStream());
                a.setPageEvent(new HeaderAndFooterStamper());
                doc.addAuthor("Matt's Super Awesome Web Site!");
                doc.addCreationDate();
                doc.addSubject("User account database report");

                doc.open();
                Paragraph p = new Paragraph("User account report",FontFactory.getFont(FontFactory.HELVETICA, 16f, Font.BOLD, BaseColor.BLACK));
                p.setAlignment(1);
                doc.add(p);
                
                Paragraph q = new Paragraph(currUser,FontFactory.getFont(FontFactory.HELVETICA, 24f, Font.BOLD, BaseColor.BLACK)),
                        r = new Paragraph("Password: "+currPass,FontFactory.getFont(FontFactory.HELVETICA, 16f, Font.ITALIC, BaseColor.BLACK));
                
                doc.add(q);
                doc.add(r);
                
                doc.close();
            }
            catch (Exception e)
            {
                throw new ServletException(e);
            }
            
          
        }
        catch (SQLException f)
        {
            throw new ServletException(f);
        }
    }
}

class HeaderAndFooterStamper extends PdfPageEventHelper
{
    Font headerFont1 = new Font(Font.FontFamily.HELVETICA, 9, 0);
    Font headerFont2 = new Font(Font.FontFamily.HELVETICA, 9, Font.BOLD);
    Font footerFont = new Font(Font.FontFamily.HELVETICA, 10, Font.ITALIC);
    PdfTemplate total; 
    
    
    public @Override void onOpenDocument(PdfWriter writer, Document document)
    {
        total = writer.getDirectContent().createTemplate(30, 16);
    }

    public @Override void onEndPage(PdfWriter writer, Document document)
    {
        PdfContentByte cb = writer.getDirectContent();
        float ps = ReporterServlet.admin? (PageSize.getRectangle("LETTER").getWidth() - 50):PageSize.POSTCARD.getHeight()-50;
        
        PdfPTable header = new PdfPTable(3);
        try
        {
            header.setTotalWidth(ps);
            header.setLockedWidth(true);
            header.getDefaultCell().setBorder(0);
            
            header.addCell(new Phrase("ICS2609 2CSB SUGUI", headerFont1));

            
            header.getDefaultCell().setHorizontalAlignment(Element.ALIGN_CENTER);
            header.addCell(new Phrase((ReporterServlet.admin?" ADMINISTRATOR REPORT":"GUEST REPORT"), headerFont2));

            
            header.getDefaultCell().setHorizontalAlignment(Element.ALIGN_RIGHT);
            header.addCell(new Phrase("As of "+ LocalDate.now().format(DateTimeFormatter.ofPattern("EEEE, dd MMMM yyyy")) + " at " + LocalTime.now().format(DateTimeFormatter.ofPattern("HH:mm:ss")), headerFont1));

            header.writeSelectedRows(0, -1, 
                (document.right() - document.left() - ps) / 2 + document.leftMargin(),
                document.top() + 20, cb);
        }
        catch (Exception de)
        {
            throw new ExceptionConverter(de);
        }

        if (ReporterServlet.admin) // full letter size, include page numbers
        {
            PdfPTable footer = new PdfPTable(3);
            try
            {
                footer.setTotalWidth(500);
                footer.setWidths(new int[]{248,248,4});
                footer.setLockedWidth(true);
                footer.getDefaultCell().setFixedHeight(30);
                footer.getDefaultCell().setBorder(0);

                footer.getDefaultCell().setHorizontalAlignment(Element.ALIGN_LEFT);
                footer.addCell(new Phrase("For "+ReporterServlet.currUser, footerFont));

                footer.getDefaultCell().setHorizontalAlignment(Element.ALIGN_RIGHT);
                footer.addCell(new Phrase("Page " + writer.getPageNumber() + " of ", footerFont));


                PdfPCell totalPageCount = new PdfPCell(Image.getInstance(total));
                totalPageCount.setHorizontalAlignment(Element.ALIGN_LEFT);
                totalPageCount.setBorder(0);
                totalPageCount.setPadding(0);
                footer.addCell(totalPageCount);

                footer.writeSelectedRows(0, -1, document.leftMargin(), document.bottom() - 10, cb);
            }
            catch (DocumentException de)
            {
                throw new ExceptionConverter(de);
            }
        }
        else // just one page, make "page 1 of 1" constant
        {
            float funny = PageSize.POSTCARD.getHeight()-100;
            PdfPTable footer = new PdfPTable(3);
            
            try
            {
                footer.setTotalWidth(funny);
                footer.setWidths(new float[]{funny/4,funny/4,4});
                footer.setLockedWidth(true);
                footer.getDefaultCell().setFixedHeight(30);
                footer.getDefaultCell().setBorder(0);

                footer.getDefaultCell().setHorizontalAlignment(Element.ALIGN_LEFT);
                footer.addCell(new Phrase("For "+ReporterServlet.currUser, footerFont));
                footer.getDefaultCell().setHorizontalAlignment(Element.ALIGN_RIGHT);
                footer.addCell(new Phrase("Page 1 of", footerFont));
                footer.getDefaultCell().setHorizontalAlignment(Element.ALIGN_LEFT);
                footer.addCell(new Phrase("1", footerFont));

                footer.writeSelectedRows(0, -1, document.leftMargin(), document.bottom() - 10, cb);
            }
            catch (DocumentException de)
            {
                throw new ExceptionConverter(de);
            }
        }
    }

    public @Override void onCloseDocument(PdfWriter writer, Document document)
    {
        ColumnText.showTextAligned(total, Element.ALIGN_LEFT,
            new Phrase(String.valueOf(writer.getPageNumber()), footerFont),
            2, 4, 0);
    }
}
 