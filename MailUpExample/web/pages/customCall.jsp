<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" import="com.mailup.*,org.json.*,java.net.*,java.io.*,org.apache.commons.codec.binary.*" pageEncoding="UTF-8"%>

<%
    // Initializing MailUpClient
    MailUpClient mailUp = (MailUpClient) request.getAttribute("mailUp");

    // Calling Method
    String callResult = "";
    if (request.getParameter("CallMethod") != null) { // CallMethod button clicked
        try {
            callResult = mailUp.callMethod(request.getParameter("lstEndpoint") + request.getParameter("txtPath"),
                    request.getParameter("lstVerb"),
                    request.getParameter("txtBody"),
                    request.getParameter("lstContentType").equals("JSON") ? ContentType.Json : ContentType.Xml, response);
        } catch (MailUpException ex) {
            callResult = "Exception with code " + ex.getStatusCode() + " and message: " + ex.getMessage();
        }
    }
%>


<!DOCTYPE html>
<html>
    <body>  
        <h3><strong>Custom method call</strong></h3>

        <div class="panel panel-default">
            <div class="panel-body">
                <form action="index.jsp" method="POST">
                    <div class="form-group row">
                        <div class="col-xs-2">
                            <label for="lstVerb">Verb</label>
                            <select name="lstVerb" class="form-control">
                                <option selected value="GET">GET</option>
                                <option value="POST">POST</option>
                                <option value="PUT">PUT</option>
                                <option value="DELETE">DELETE</option>
                            </select>
                        </div>

                        <div class="col-xs-2">
                            <label for="lstContentType">Content-Type</label>
                            <select name="lstContentType" class="form-control">
                                <option selected value="JSON">JSON</option>
                                <option value="XML">XML</option>
                            </select>
                        </div>

                        <div class="col-xs-2">
                            <label for="lstEndpoint">Endpoint</label>
                            <select name="lstEndpoint" class="form-control">
                                <option selected value="<%= mailUp.getConsoleEndpoint()%>">Console</option>
                                <option value="<%= mailUp.getMailstatisticsEndpoint()%>">MailStatistics</option>
                            </select>
                        </div>

                        <div class="col-xs-6">
                            <label for="txtPath">Path</label>
                            <input type="text" name="txtPath" value="/Console/Authentication/Info" class="form-control"/>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="txtBody">Body</label>
                        <textarea class="form-control" rows="5" cols="60" name="txtBody"></textarea>
                    </div>

                    <button type="submit" name="CallMethod" class="btn btn-success">Call Method</button>
                </form>
            </div>
        </div>
        <div class="panel panel-default">
            <div class="panel-body">
                <div class="form-group example-body">
                    <label>Response</label>
                    <div id="pResultString"><%= callResult%></div>                
                </div>
            </div>
        </div>
    </body>
</html>
