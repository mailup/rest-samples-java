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
    String templateWarning = (String) request.getAttribute("templateWarning");

    // Running Examples
    String exampleResult = "";

    // EXAMPLE 4 - CREATE A MESSAGE FROM TEMPLATE
    if (request.getParameter("RunExample4") != null) {
        try {

            // Get the available template list
            exampleResult += String.format(templateHeader, "Get the available template list");

            String url = "/Console/List/" + idList + "/Templates";

            exampleResult += String.format(templateRequest, "GET", "JSON", "Console", url, "");
            String result = mailUp.callMethod(mailUp.getConsoleEndpoint() + url, "GET", null, ContentType.Json, response);
            exampleResult += String.format(templateResponse, result);

            JSONObject obj = new JSONObject(result);
            JSONArray arr = obj.getJSONArray("Items");

            int templateId = -1;
            if (arr.length() > 0) {
                templateId = arr.getJSONObject(0).getInt("Id");
            }

            if (templateId < 0) {
                exampleResult += String.format(templateWarning, "Template doesn't exist");
            }

            // Create the new message
            exampleResult += String.format(templateHeader, "Create the new message");

            url = "/Console/List/" + idList + "/Email/Template/" + templateId;

            exampleResult += String.format(templateRequest, "POST", "JSON", "Console", url, "");
            result = mailUp.callMethod(mailUp.getConsoleEndpoint() + url, "POST", null, ContentType.Json, response);
            exampleResult += String.format(templateResponse, result);

            obj = new JSONObject(result);

            session.setAttribute("emailId", new Integer(obj.getInt("idMessage")));

            // Request for messages list
            exampleResult += String.format(templateHeader, "Request for messages list");

            url = "/Console/List/" + idList + "/Emails";
            exampleResult += String.format(templateRequest, "GET", "JSON", "Console", url, "");
            result = mailUp.callMethod(mailUp.getConsoleEndpoint() + url, "GET", null, ContentType.Json, response);
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
        <form action="index.jsp#examplel4" method="POST">
            <div class="panel-group" id="examplel4">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h4 class="panel-title">
                            <a data-toggle="collapse" href="#collapseRunExample4">Run example code 4 - Create a message from template</a>
                        </h4>
                    </div>
                    <div id="collapseRunExample4" class="panel-collapse collapse ${submitted ? 'in' : ''}">
                        <div class="panel-body">
                            <button type="submit" name="RunExample4" class="btn btn-success">Run example code 4 - Create a message from template</button>
                            <div id="pExampleResultString" class="example-result-string"><%=exampleResult%></div>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </body>
</html>
