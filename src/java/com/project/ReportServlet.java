package com.project;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import java.io.IOException;
import java.sql.*;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.http.*;

public class ReportServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("error_session.jsp");
            return;
        }

        String currentUser = (String) session.getAttribute("user");
        String currentRole = (String) session.getAttribute("role");
        
        // 8.5 x 11 dimensions
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "inline; filename=" + currentRole + "_report.pdf");

        try {
            //set page size based on role
            Document document;
            if ("admin".equals(currentRole)) {
                document = new Document(PageSize.LETTER); // Admin Requirement
            } else {
                Rectangle customSize = new Rectangle(400, 300); // Guest Requirement: Smaller/Customized
                document = new Document(customSize);
            }

            PdfWriter writer = PdfWriter.getInstance(document, response.getOutputStream());
            
            //attach the Header/Footer Event handler (Owner and Page X of Y)
            ReportFooterEvent event = new ReportFooterEvent(currentUser);
            writer.setPageEvent(event);

            document.open();

            //font
            Font boldTitleFont = new Font(Font.FontFamily.HELVETICA, 16, Font.BOLD);
            Font normalFont = new Font(Font.FontFamily.HELVETICA, 12, Font.NORMAL);

            //type of report (bold) placed on top center
            String reportTitleStr = "admin".equals(currentRole) ? "ADMIN REPORT" : "GUEST REPORT";
            Paragraph title = new Paragraph(reportTitleStr, boldTitleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            title.setSpacingAfter(20f);
            document.add(title);

            //date and time stamp
            Paragraph timestamp = new Paragraph("Generated on: " + new Date().toString(), normalFont);
            timestamp.setSpacingAfter(20f);
            document.add(timestamp);

            //database connection & table generation
            String driver = getServletConfig().getInitParameter("dbDriver");
            String url = getServletConfig().getInitParameter("dbURL");
            String dbUser = getServletConfig().getInitParameter("dbUser");
            String dbPass = getServletConfig().getInitParameter("dbPass");
            String secretKey = getServletContext().getInitParameter("secretKey");
            String cipherAlgorithm = getServletContext().getInitParameter("cipherAlgorithm");

            Class.forName(driver);
            Connection conn = DriverManager.getConnection(url, dbUser, dbPass);

            PdfPTable table = new PdfPTable(2);
            table.setWidthPercentage(100);

            //using the createCenteredCell helper method
            if ("admin".equals(currentRole)) {
                // ADMIN: All records, username and role only
                table.addCell(createCenteredCell("Username"));
                table.addCell(createCenteredCell("Role"));

                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT username, role FROM USERS");
                while (rs.next()) {
                    table.addCell(createCenteredCell(rs.getString("username")));
                    table.addCell(createCenteredCell(rs.getString("role")));
                }
            } else {
                // GUEST: Only their details, username and decrypted password
                table.addCell(createCenteredCell("Username"));
                table.addCell(createCenteredCell("Decrypted Password"));

                PreparedStatement ps = conn.prepareStatement("SELECT username, password FROM USERS WHERE username = ?");
                ps.setString(1, currentUser);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    table.addCell(createCenteredCell(rs.getString("username")));
                    
                    String encryptedPassword = rs.getString("password");
                    if (encryptedPassword != null && !encryptedPassword.isEmpty()) {
                        String decryptedPassword = CryptoUtil.decrypt(encryptedPassword, secretKey, cipherAlgorithm);
                        table.addCell(createCenteredCell(decryptedPassword));
                    } else {
                        table.addCell(createCenteredCell("NO PASSWORD SET"));
                    }
                }
            }
            conn.close();
            document.add(table);
            document.close();

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    //creates a styled cell with padding and centered text 
    private PdfPCell createCenteredCell(String text) {
        // if text is null, make it an empty string so it doesn't crash
        if (text == null) {
            text = "N/A";
        }
        
        PdfPCell cell = new PdfPCell(new Phrase(text));
        
        //padding (8 points of space inside the cell)
        cell.setPadding(8f); 
        cell.setPaddingBottom(10f); // A little extra on the bottom looks nice
        
        //center the text horizontally and vertically
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
        
        return cell;
    }

    //handles page X of Y and Owner Footers --
    class ReportFooterEvent extends PdfPageEventHelper {
        private String owner;
        private PdfTemplate total;
        private Font italicFont;

        public ReportFooterEvent(String owner) {
            this.owner = owner;
            this.italicFont = new Font(Font.FontFamily.HELVETICA, 10, Font.ITALIC);
        }

        @Override
        public void onOpenDocument(PdfWriter writer, Document document) {
            // Create template for the 'Y' in Page X of Y
            total = writer.getDirectContent().createTemplate(30, 16);
        }

        @Override
        public void onEndPage(PdfWriter writer, Document document) {
            PdfContentByte cb = writer.getDirectContent();

            // 1. Owner (italics) on lower left
            ColumnText.showTextAligned(cb, Element.ALIGN_LEFT,
                    new Phrase("Owner: " + owner, italicFont),
                    document.leftMargin(), document.bottomMargin() - 10, 0);

            // 2. Page X (italics) on lower right
            String text = "Page " + writer.getPageNumber() + " of ";
            float textBase = document.bottomMargin() - 10;
            
            // Align RIGHT means the text ends exactly at document.right() - 15
            ColumnText.showTextAligned(cb, Element.ALIGN_RIGHT,
                    new Phrase(text, italicFont),
                    document.right() - 15, textBase, 0);
            
            // We shift the template slightly to the right to leave space after "of"
            cb.addTemplate(total, document.right() - 15 + 4, textBase);
        }

        @Override
        public void onCloseDocument(PdfWriter writer, Document document) {
            // Fill in the 'Y' (total pages) at the very end
            ColumnText.showTextAligned(total, Element.ALIGN_LEFT,
                    new Phrase(String.valueOf(writer.getPageNumber()), italicFont),
                    0, 0, 0);
        }
    }
}