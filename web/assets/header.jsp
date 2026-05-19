<%-- 
    Document   : header
    Created on : 01-Mar-2026, 17:38:30
    Author     : Adrian
--%>
<%@page session="false"%>
<header id="desktop" style="height:80px">
    <table id="ribbon" style="height:60px">
        <tr>
            <td id="localcell" rowspan="2">
                <a href="./" id="local"><div>
                    <%= getServletContext().getInitParameter("GlobalHeader") %>
                </div></a>
            </td>
            <td id="himenucell">
                <nav class="himenu">
                    <%=
                       request.getSession(false) != null?
                               "<a class=\"himenuit\" href=\"./exit\">Log out</a>":
                               "<a class=\"himenuit\" href=\"./\">Log in</a>"
                    %>
                </nav>
            </td>
        </tr>
        <tr id="bodyrow">
            <td>
                <a href="./" id="guide">
                    <img src="">
                </a>
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