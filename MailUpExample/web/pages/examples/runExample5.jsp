<%@page contentType="text/html" import="com.mailup.*,org.json.*,java.net.*,java.io.*,org.apache.commons.codec.binary.*" pageEncoding="UTF-8"%>
<%@page import="java.util.ResourceBundle" %>

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

    // EXAMPLE 5 - CREATE A MESSAGE WITH IMAGES AND ATTACHMENTS
    if (request.getParameter("RunExample5") != null) {
        try {

            // Image bytes can be obtained from file, database or any other source
            exampleResult += String.format(templateHeader, "Upload an image");

            URL img = new URL("https://www.mailup.it/risorse/logo/512x512.png");
            InputStream str = img.openStream();
            ByteArrayOutputStream buffer = new ByteArrayOutputStream();

            int nRead;
            byte[] data = new byte[16384];

            while ((nRead = str.read(data, 0, data.length)) != -1) {
                buffer.write(data, 0, nRead);
            }

            buffer.flush();

            byte[] image = buffer.toByteArray();
            String base64 = Base64.encodeBase64String(image);

            // Upload an image
            String url = "/Console/List/" + idList + "/Images";
            String imageRequest = String.format("{\"Base64Data\":\"%s\",\"Name\":\"%s\"}", base64, "Avatar.png");

            exampleResult += String.format(templateRequest, "POST", "JSON", "Console", url, imageRequest);
            String result = mailUp.callMethod(mailUp.getConsoleEndpoint() + url, "POST", imageRequest, ContentType.Json, response);
            exampleResult += String.format(templateResponse, result);

            // Get the images available
            exampleResult += String.format(templateHeader, "Get the images available");

            url = "/Console/List/" + idList + "/Images";

            exampleResult += String.format(templateRequest, "GET", "JSON", "Console", url, "");
            result = mailUp.callMethod(mailUp.getConsoleEndpoint() + url, "GET", null, ContentType.Json, response);
            exampleResult += String.format(templateResponse, result);

            String imgSrc = "";
            JSONArray arr = new JSONArray(result);
            if (arr.length() > 0) {
                imgSrc = arr.getString(0);
            }

            // Create and save "hello" message
            exampleResult += String.format(templateHeader, "Create and save \"hello\" message");

            String message = "<html><body><p>Hello</p><img src=\"http://" + imgSrc.replace("\\", "/") + "\" /></body></html>";

            JSONObject email = new JSONObject();
            email.put("Subject", "Test Message JAVA");
            email.put("idList", idList);
            email.put("Content", message);
            email.put("Embed", true);
            email.put("IsConfirmation", true);
            email.put("Fields", new JSONArray());
            email.put("Notes", "Some notes");
            email.put("Tags", new JSONArray());
            JSONObject trackingInfo = new JSONObject();
            trackingInfo.put("CustomParams", "");
            trackingInfo.put("Enabled", true);
            JSONArray protocols = new JSONArray();
            protocols.put("http");
            trackingInfo.put("Protocols", protocols);
            email.put("TrackingInfo", trackingInfo);

            url = "/Console/List/" + idList + "/Email";

            exampleResult += String.format(templateRequest, "POST", "JSON", "Console", url, email.toString());
            result = mailUp.callMethod(mailUp.getConsoleEndpoint() + url, "POST", email.toString(), ContentType.Json, response);
            exampleResult += String.format(templateResponse, result);

            JSONObject obj = new JSONObject(result);

            session.setAttribute("emailId", new Integer(obj.getInt("idMessage")));
            emailId = obj.getInt("idMessage");

            // Add an attachment
            exampleResult += String.format(templateHeader, "Add an attachment");

            String attachment = "QmFzZSA2NCBTdHJlYW0="; // Base64 String
            String attachmentRequest = String.format("{\"Base64Data\":\"%s\",\"Name\":\"%s\",\"Slot\":%s,\"idList\":%s,\"idMessage\":%s}",
                    attachment, "TestFile.txt", "1", idList, emailId);

            url = "/Console/List/" + idList + "/Email/" + emailId + "/Attachment/1";

            exampleResult += String.format(templateRequest, "POST", "JSON", "Console", url, attachmentRequest);
            result = mailUp.callMethod(mailUp.getConsoleEndpoint() + url, "POST", attachmentRequest, ContentType.Json, response);
            exampleResult += String.format(templateResponse, result);

            // Retreive message details
            exampleResult += String.format(templateHeader, "Retreive message details");

            url = "/Console/List/" + idList + "/Email/" + emailId;

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
        <form action="index.jsp#examplel5" method="POST">
            <div class="panel-group" id="examplel5">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h4 class="panel-title">
                            <a data-toggle="collapse" href="#collapseRunExample5">Run example code 5 - Create a message from scratch</a>
                        </h4>
                    </div>
                    <div id="collapseRunExample5" class="panel-collapse collapse ${submitted ? 'in' : ''}">
                        <div class="panel-body">
                            <button type="submit" name="RunExample5" class="btn btn-success">Run example code 5 - Create a message from scratch</button>
                            <div id="pExampleResultString" class="example-result-string"><%=exampleResult%></div>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </body>
</html>
