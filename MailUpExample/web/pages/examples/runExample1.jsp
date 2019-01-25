<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" import="com.mailup.*,org.json.*,java.net.*,java.io.*,org.apache.commons.codec.binary.*" pageEncoding="UTF-8"%>

<%
    // Initializing MailUpClient
    MailUpClient mailUp = (MailUpClient) request.getAttribute("mailUp");
    String templateRequest = (String) request.getAttribute("templateRequest");
    String idList = (String) request.getAttribute("idList");
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

    // EXAMPLE 1 - IMPORT RECIPIENTS INTO NEW GROUP
    // List ID = 1 is used in all example calls
    if (request.getParameter("RunExample1") != null) { // CallMethod button clicked
        try {
            exampleResult += String.format(templateHeader, "Give a default list id (use idList = " + idList + "), request for user visible groups");
            String url = "/Console/List/" + idList + "/Groups";

            exampleResult += String.format(templateRequest, "GET", "JSON", "Console", url, "");
            String result = mailUp.callMethod(mailUp.getConsoleEndpoint() + url, "GET", null, ContentType.Json, response);
            exampleResult += String.format(templateResponse, result);

            JSONObject obj = new JSONObject(result);
            JSONArray arr = obj.getJSONArray("Items");
            for (int i = 0; i < arr.length(); i++) {
                JSONObject group = arr.getJSONObject(i);
                if ("test import".equals(group.getString("Name"))) {
                    groupId = group.getInt("idGroup");
                }
            }

            // If the list does not contain a group named 'test import', create it
            if (groupId == -1) {
                exampleResult += String.format(templateHeader, "If the list does not contain a group named \"test import\", create it");

                groupId = 100;

                url = "/Console/List/" + idList + "/Group";
                String groupRequest = "{\"Deletable\":true,\"Name\":\"test import\",\"Notes\":\"test import\"}";

                exampleResult += String.format(templateRequest, "POST", "JSON", "Console", url, groupRequest);
                result = mailUp.callMethod(mailUp.getConsoleEndpoint() + url, "POST", groupRequest, ContentType.Json, response);
                exampleResult += String.format(templateResponse, result);

                obj = new JSONObject(result);
                if ("test import".equals(obj.getString("Name"))) {
                    groupId = obj.getInt("idGroup");
                }

            }
            session.setAttribute("groupId", new Integer(groupId));

            // Request for dynamic fields to map recipient name and surname
            exampleResult += String.format(templateHeader, "Request for dynamic fields to map recipient name and surname");

            url = "/Console/Recipient/DynamicFields";

            exampleResult += String.format(templateRequest, "POST", "JSON", "Console", url, "");
            result = mailUp.callMethod(mailUp.getConsoleEndpoint() + url, "GET", null, ContentType.Json, response);
            exampleResult += String.format(templateResponse, result);

            // Import recipients to group
            exampleResult += String.format(templateHeader, "Import recipients to group");

            url = "/Console/Group/" + groupId + "/Recipients";
            String recipientRequest = "[{\"Email\":\"test@test.test\",\"Fields\":[{\"Description\":\"String description\",\"Id\":1,\"Value\":\"String value\"}],\"MobileNumber\":\"\",\"MobilePrefix\":\"\",\"Name\":\"John Smith\"}]";

            exampleResult += String.format(templateRequest, "POST", "JSON", "Console", url, recipientRequest);
            result = mailUp.callMethod(mailUp.getConsoleEndpoint() + url, "POST", recipientRequest, ContentType.Json, response);
            exampleResult += String.format(templateResponse, result);

            int importId = Integer.parseInt(result);

            // Check the import result
            exampleResult += String.format(templateHeader, "Check the import result");

            url = "/Console/Import/" + importId;

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
        <form action="index.jsp#examplel1" method="POST">
            <div class="panel-group" id="examplel1">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h4 class="panel-title">
                            <a data-toggle="collapse" href="#collapseRunExample1">Run example code 1 - Import recipients</a>
                        </h4>
                    </div>

                    <div id="collapseRunExample1" class="panel-collapse collapse ${submitted ? 'in' : ''}">
                        <div class="panel-body">
                            <button type="submit" name="RunExample1" class="btn btn-success">Run example code 1 - Import recipients</button> 
                            <div id="pExampleResultString" class="example-result-string"><%=exampleResult%></div>
                        </div>
                    </div>
                </div>
            </div>  
        </form>
    </body>
</html>
