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
    int emailId = -1;

    if (session.getAttribute("emailId") != null) {
        emailId = (Integer) session.getAttribute("emailId");
    }
    // EXAMPLE 8 - DISPLAY STATISTICS FOR A MESSAGE SENT AT EXAMPLE 7
    if (request.getParameter("RunExample8") != null) {
        try {

            // Request (to MailStatisticsService.svc) for paged message views list for the previously sent message
            exampleResult += String.format(templateHeader, "Request (to MailStatisticsService.svc) for paged message views list for the previously sent message");

            int hours = 4;
            String url = "/Message/" + emailId + "/List/Views?pageSize=5&pageNum=0";

            exampleResult += String.format(templateRequest, "GET", "JSON", "MailStatistics", url, "");
            String result = mailUp.callMethod(mailUp.getMailstatisticsEndpoint() + url, "GET", null, ContentType.Json, response);
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
        <form action="index.jsp#examplel8" method="POST">
            <div class="panel-group" id=examplel8"">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h4 class="panel-title">
                            <a data-toggle="collapse" href="#collapseRunExample8">Run example code 8 - Retreive statistics</a>
                        </h4>
                    </div>
                    <div id="collapseRunExample8" class="panel-collapse collapse ${submitted ? 'in' : ''}">
                        <div class="panel-body">
                            <button type="submit" name="RunExample8" class="btn btn-success">Run example code 8 - Retreive statistics</button>
                            <div id="pExampleResultString" class="example-result-string"><%=exampleResult%></div>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </body>
</html>
