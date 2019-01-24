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

    // EXAMPLE 3 - UPDATE A RECIPIENT DETAIL
    if (request.getParameter("RunExample3") != null) {
        try {

            // Request for existing subscribed recipients
            exampleResult += String.format(templateHeader, "Request for existing subscribed recipients");

            String url = "/Console/List/" + idList + "/Recipients/Subscribed";

            exampleResult += String.format(templateRequest, "GET", "JSON", "Console", url, "");
            String result = mailUp.callMethod(mailUp.getConsoleEndpoint() + url, "GET", null, ContentType.Json, response);
            exampleResult += String.format(templateResponse, result);

            JSONObject obj = new JSONObject(result);

            JSONArray arr = obj.getJSONArray("Items");
            if (arr.length() > 0) {
                JSONObject recipient = arr.getJSONObject(0);
                JSONArray fields = recipient.getJSONArray("Fields");

                // Modify a recipient from the list
                exampleResult += String.format(templateHeader, "Modify a recipient from the list");

                if (fields.length() == 0) {
                    JSONObject o = new JSONObject();
                    o.put("Id", 1);
                    o.put("Value", "Updated value");
                    o.put("Description", "");
                    fields.put(o);
                } else {
                    JSONObject o = fields.getJSONObject(0);
                    o.put("Id", 1);
                    o.put("Value", "Updated value");
                    o.put("Description", "");
                }

                exampleResult += String.format(templateResponse, recipient.toString());

                // Update the modified recipient
                exampleResult += String.format(templateHeader, "Update the modified recipient");

                url = "/Console/Recipient/Detail";

                exampleResult += String.format(templateRequest, "PUT", "JSON", "Console", url, recipient.toString());
                mailUp.callMethod(mailUp.getConsoleEndpoint() + url, "PUT", recipient.toString(), ContentType.Json, response);
                exampleResult += String.format(templateResponse, "OK");
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
        <form action="index.jsp#examplel3" method="POST">
            <div class="panel-group" id="examplel3">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h4 class="panel-title">
                            <a data-toggle="collapse" href="#collapseRunExample3">Run example code 3 - Update a recipient</a>
                        </h4>
                    </div>
                    <div id="collapseRunExample3" class="panel-collapse collapse ${submitted ? 'in' : ''}">
                        <div class="panel-body">
                            <button type="submit" name="RunExample3" class="btn btn-success">Run example code 3 - Update a recipient</button>
                            <div id="pExampleResultString" class="example-result-string"><%=exampleResult%></div>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </body>
</html>
