<%-- 
    Document   : rightbar
    Created on : 24-May-2026, 09:20:43
    Author     : Adrian
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<aside class="column" id="right">
    <h1>User account information</h1>
    <ul>
        <li><p class="tocitem1"><%= currUser %></p></li>
        <li><p class="tocitem2"><%= appelation %></p></li>
        <li><p class="tocitem3" style="font-size:smaller; font-weight:normal; padding-left:1rem; font-style:italic"><%= currUserEmail %></p></li>
    </ul>
</aside>