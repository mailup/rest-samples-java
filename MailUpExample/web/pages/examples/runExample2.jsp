<%@page contentType="text/html" import="com.mailup.*,org.json.*,java.net.*,java.io.*,org.apache.commons.codec.binary.*" pageEncoding="UTF-8"%>

<%
    // Initializing MailUpClient
    MailUpClient mailUp = (MailUpClient) request.getAttribute("mailUp");
    String templateRequest = (String) request.getAttribute("templateRequest");
    String templateResponse = (String) request.getAttribute("templateResponse");
    String templateHeader = (String) request.getAttribute("templateHeader");
    String templateCompleted = (String) request.getAttribute("templateCompleted");
    String templateError = (String) request.getAttribute("templateError");

    // Running Examples
    String exampleResult = "";
    int groupId = -1;

    if (session.getAttribute("groupId") != null) {
        groupId = (Integer) session.getAttribute("groupId");
    }

    // EXAMPLE 2 - UNSUBSCRIBE A RECIPIENT FROM A GROUP
    if (request.getParameter("RunExample2") != null) {
        try {

            // Request for recipient in a group
            exampleResult += String.format(templateHeader, "Request for recipient in a group");

            String url = "/Console/Group/" + groupId + "/Recipients";

            exampleResult += String.format(templateRequest, "GET", "JSON", "Console", url, "");
            String result = mailUp.callMethod(mailUp.getConsoleEndpoint() + url, "GET", null, ContentType.Json, response);
            exampleResult += String.format(templateResponse, result);

            JSONObject obj = new JSONObject(result);

            JSONArray arr = obj.getJSONArray("Items");
            if (arr.length() > 0) {
                JSONObject recipient = arr.getJSONObject(0);
                int recipientId = recipient.getInt("idRecipient");

                // Pick up a recipient and unsubscribe it
                exampleResult += String.format(templateHeader, "Pick up a recipient and unsubscribe it");

                url = "/Console/Group/" + groupId + "/Unsubscribe/" + recipientId;

                exampleResult += String.format(templateRequest, "DELETE", "JSON", "Console", url, "");
                mailUp.callMethod(mailUp.getConsoleEndpoint() + url, "DELETE", null, ContentType.Json, response);
                exampleResult += String.format(templateResponse, result);
            }

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
        <form action="index.jsp#examplel2" method="POST">
            <div class="panel-group" id="examplel2">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h4 class="panel-title">
                            <a data-toggle="collapse" href="#collapseRunExample2">Run example code 2 - Unsubscribe a recipient</a>
                        </h4>
                    </div>
                    <div id="collapseRunExample2" class="panel-collapse collapse ${submitted ? 'in' : ''}">
                        <div class="panel-body">
                            <button type="submit" name="RunExample2" class="btn btn-success">Run example code 2 - Unsubscribe a recipient</button>
                            <div id="pExampleResultString" class="example-result-string"><%=exampleResult%></div>
                        </div>
                    </div>
                </div>
            </div>  
        </form>
    </body>
</html>
