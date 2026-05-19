<%-- 
    Document   : header
    Created on : 01-Mar-2026, 17:38:30
    Author     : Adrian
--%>
<%@page session="false"%>
<header id="desktop" style="height:40px">
    <table id="ribbon" style="height:40px">
        <tr id="bodyrow">
            <td id="localcell" style="width:max-content;height:40px">
                <a id="local"><div style="height:40px;width:100%">
                    <%= getServletContext().getInitParameter("GlobalHeader") %>
                </div></a>
            </td>
        </tr>
        <tr id="lomenurow">
            <td id="lomenucell" colspan="2">
                <nav class="lomenu">
                    <!-- <a class="lomenuit sitemaplink" href="./map.php">View sitemap</a> -->
                </nav>
            </td>
        </tr>   
    </table>
</header>