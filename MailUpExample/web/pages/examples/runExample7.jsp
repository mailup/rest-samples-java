<%@page contentType="text/html" import="com.mailup.*,org.json.*,java.net.*,java.io.*,org.apache.commons.codec.binary.*" pageEncoding="UTF-8"%>

<%
    // Initializing MailUpClient
    MailUpClient mailUp = (MailUpClient) request.getAttribute("mailUp");
    String idList = (String) request.getAttribute("idList");
    String templateRequest = (String) request.getAttribute("templateRequest");
    String templateResponse = (String) request.getAttribute("templateResponse");
    String templateHeader = (String) request.getAttribute("templateHeader");
    String templateCompleted = (String) request.getAttribute("templateCompleted");
    String templateError = (String) request.getAttribute("templateError");

    // Running Examples
    String exampleResult = "";
    int emailId = -1;

    if (session.getAttribute("emailId") != null) {
        emailId = (Integer) session.getAttribute("emailId");
    }

    // EXAMPLE 7 - SEND A MESSAGE
    if (request.getParameter("RunExample7") != null) {
        try {

            // Get the list of the existing messages
            exampleResult += String.format(templateHeader, "Get the list of the existing messages");

            String url = "/Console/List/" + idList + "/Emails";

            exampleResult += String.format(templateRequest, "GET", "JSON", "Console", url, "");
            String result = mailUp.callMethod(mailUp.getConsoleEndpoint() + url, "GET", null, ContentType.Json, response);
            exampleResult += String.format(templateResponse, result);

            JSONObject obj = new JSONObject(result);

            JSONArray arr = obj.getJSONArray("Items");
            if (arr.length() > 0) {
                JSONObject email = arr.getJSONObject(0);
                emailId = email.getInt("idMessage");
            }
            session.setAttribute("emailId", new Integer(emailId));

            // Send email to all recipients in the list
            exampleResult += String.format(templateHeader, "Send email to all recipients in the list");

            url = "/Console/List/" + idList + "/Email/" + emailId + "/Send";

            exampleResult += String.format(templateRequest, "POST", "JSON", "Console", url, "");
            result = mailUp.callMethod(mailUp.getConsoleEndpoint() + url, "POST", null, ContentType.Json, response);
            exampleResult += String.format(templateResponse, result);

            exampleResult += templateCompleted;

        } catch (MailUpException ex) {
            exampleResult += String.format(templateError, ex.getStatusCode() + ": " + ex.getMessage());
        } catch (Exception ex) {
            exampleResult += String.format(templateError, ex.getMessage());
        }
    }

    pageContext.setAttribute("submitted", !exampleResult.isEmpty());
%>

<!DOCTYPE html>
<html>
    <body>
        <form action="index.jsp#examplel7" method="POST">
            <div class="panel-group" id="examplel7">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h4 class="panel-title">
                            <a data-toggle="collapse" href="#collapseRunExample7">Run example code 7 - Send a message</a>
                        </h4>
                    </div>
                    <div id="collapseRunExample7" class="panel-collapse collapse ${submitted ? 'in' : ''}">
                        <div class="panel-body">
                            <button type="submit" name="RunExample7" class="btn btn-success">Run example code 7 - Send a message</button>
                            <div id="pExampleResultString" class="example-result-string"><%=exampleResult%></div>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </body>
</html>
