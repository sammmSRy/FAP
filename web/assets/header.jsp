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
                <a href="${pageContext.request.contextPath}" id="local"><div>
                    <%= getServletContext().getInitParameter("GlobalHeader") %>
                </div></a>
            </td>
            <td id="himenucell">
                <nav class="himenu">
                    <%=
                       request.getSession(false) != null?
                               "<a class=\"himenuit\" href=\""+request.getContextPath()+"/exit\">Log out</a>":
                               "<a class=\"himenuit\" href=\""+request.getContextPath()+"/\">Log in</a>"
                    %>
                </nav>
            </td>
        </tr>
        <tr id="bodyrow">
            <td>
                <a href="${pageContext.request.contextPath}" id="guide">
                    <img src="">
                </a>
            </td>
        </tr>
        <tr id="lomenurow">
            <td id="lomenucell" colspan="2">
                <nav class="lomenu">
                    <% if ((Integer)sesh.getAttribute("type") == 2) { %>
                        <a class="lomenuit sitemaplink" href="${pageContext.request.contextPath}/admin">Dashboard</a>
                        <a class="lomenuit sitemaplink" href="${pageContext.request.contextPath}/admin/staff.jsp">Stakeholders</a>
                        <a class="lomenuit sitemaplink" href="${pageContext.request.contextPath}/courses">Courses</a>
                        <a class="lomenuit sitemaplink" href="${pageContext.request.contextPath}/activities">Activities</a>
                        <a class="lomenuit sitemaplink" href="${pageContext.request.contextPath}/timeline">Recent events</a>
                    <% } else if ((Integer)sesh.getAttribute("type") == 1) { %> 
                        <a class="lomenuit sitemaplink" href="${pageContext.request.contextPath}/instructor">Dashboard</a>
                        <a class="lomenuit sitemaplink" href="${pageContext.request.contextPath}/instructor/students.jsp">Students</a>
                        <a class="lomenuit sitemaplink" href="${pageContext.request.contextPath}/courses">Courses</a>
                        <a class="lomenuit sitemaplink" href="${pageContext.request.contextPath}/activities">Activities</a>
                    <% } else if ((Integer)sesh.getAttribute("type") == 0) { %> 
                        <a class="lomenuit sitemaplink" href="${pageContext.request.contextPath}/student">Dashboard</a>
                        <a class="lomenuit sitemaplink" href="${pageContext.request.contextPath}/courses">My Courses</a>
                        <a class="lomenuit sitemaplink" href="${pageContext.request.contextPath}/activities">My Activities</a>
                    <% } %>
                </nav>
            </td>
        </tr>   
    </table>
</header>