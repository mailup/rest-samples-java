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
    int emailId = -1;

    if (session.getAttribute("emailId") != null) {
        emailId = (Integer) session.getAttribute("emailId");
    }

    // EXAMPLE 6 - TAG A MESSAGE
    if (request.getParameter("RunExample6") != null) {
        try {

            // Create a new tag
            exampleResult += String.format(templateHeader, "Create a new tag");

            String url = "/Console/List/" + idList + "/Tag";

            exampleResult += String.format(templateRequest, "POST", "JSON", "Console", url, "\"test tag\"");
            String result = mailUp.callMethod(mailUp.getConsoleEndpoint() + url, "POST", "\"test tag\"", ContentType.Json, response);
            exampleResult += String.format(templateResponse, result);

            JSONObject obj = new JSONObject(result);

            int tagId = -1;
            tagId = obj.getInt("Id");

            if (tagId < 0) {
                exampleResult += String.format(templateWarning, "Tag doesn't exist");
            }

            // Pick up a message and retrieve detailed informations
            exampleResult += String.format(templateHeader, "Pick up a message and retrieve detailed informations");

            url = "/Console/List/" + idList + "/Email/" + emailId;

            exampleResult += String.format(templateRequest, "GET", "JSON", "Console", url, "");
            result = mailUp.callMethod(mailUp.getConsoleEndpoint() + url, "GET", null, ContentType.Json, response);
            exampleResult += String.format(templateResponse, result);

            obj = new JSONObject(result);

            // Add the tag to the message details and save
            exampleResult += String.format(templateHeader, "Add the tag to the message details and save");

            JSONArray tags = new JSONArray();
            JSONObject tag = new JSONObject();
            tag.put("Id", tagId);
            tag.put("Enabled", true);
            tag.put("Name", "test tag");
            tags.put(tag);
            obj.put("Tags", tags);

            url = "/Console/List/" + idList + "/Email/" + emailId;

            exampleResult += String.format(templateRequest, "PUT", "JSON", "Console", url, obj.toString());
            result = mailUp.callMethod(mailUp.getConsoleEndpoint() + url, "PUT", obj.toString(), ContentType.Json, response);
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
        <form action="index.jsp#examplel6" method="POST">
            <div class="panel-group" id="examplel6">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h4 class="panel-title">
                            <a data-toggle="collapse" href="#collapseRunExample6">Run example code 6 - Tag a message</a>
                        </h4>
                    </div>
                    <div id="collapseRunExample6" class="panel-collapse collapse ${submitted ? 'in' : ''}">
                        <div class="panel-body">
                            <button type="submit" name="RunExample6" class="btn btn-success">Run example code 6 - Tag a message</button>
                            <div id="pExampleResultString" class="example-result-string"><%=exampleResult%></div>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </body>
</html>
