<%@page contentType="text/html" import="com.mailup.*,org.json.*,java.net.*,java.io.*,org.apache.commons.codec.binary.*" pageEncoding="UTF-8"%>
<%! 
    
private static String MAILUP_CLIENT_ID = "364f66d0-89d3-414d-af72-3ad29b066cce";
private static String MAILUP_CLIENT_SECRET = "3a59bf03-1938-43fb-a1d7-09d56e7b2c26";
private static String MAILUP_CALLBACK_URI = "http://127.0.0.1:8080/MailUpExample/index.jsp";

%><%

    // Initializing MailUpClient
    MailUpClient mailUp = new MailUpClient(MAILUP_CLIENT_ID, MAILUP_CLIENT_SECRET, MAILUP_CALLBACK_URI, request);
    
    // Logging In
    if (request.getParameter("LogOn") != null) { // LogOn button clicked
        mailUp.logOn(response);
    } else if (request.getParameter("code") != null) { // code returned by MailUp
        mailUp.retreiveAccessToken(request.getParameter("code"), response);
    }

    if(request.getParameter("LogOnWithUsernamePassword") != null) {
        mailUp.logOnWithUsernamePassword(request.getParameter("txtUsr"), request.getParameter("txtPwd"), response);
    }
    
    // Calling Method
    String callResult = "";
    if (request.getParameter("CallMethod") != null) { // CallMethod button clicked
        try {
            callResult = mailUp.callMethod(request.getParameter("lstEndpoint") + request.getParameter("txtPath"), 
                request.getParameter("lstVerb"), 
                request.getParameter("txtBody"), 
                request.getParameter("lstContentType").equals("JSON")?ContentType.Json:ContentType.Xml, response);
        } catch (MailUpException ex) {
            callResult = "Exception with code " +ex.getStatusCode() + " and message: " + ex.getMessage();
        }
    }
    
    // Running Examples
    String exampleResult = "";
    int groupId = -1;
    int emailId = -1;
    
    if (session.getAttribute("groupId") != null) groupId = (Integer)session.getAttribute("groupId");
    if (session.getAttribute("emailId") != null) emailId = (Integer)session.getAttribute("emailId");
    
    // EXAMPLE 1 - IMPORT RECIPIENTS INTO NEW GROUP
    // List ID = 1 is used in all example calls
    if (request.getParameter("RunExample1") != null) { // CallMethod button clicked
        try {
            
            // Given a default list id (use idList = 1), request for user visible groups
            String url = mailUp.getConsoleEndpoint() + "/Console/List/1/Groups";
            String result = mailUp.callMethod(url, "GET", null, ContentType.Json, response);
            JSONObject obj = new JSONObject(result);
            JSONArray arr = obj.getJSONArray("Items");
            for (int i = 0; i < arr.length(); i++) {
                JSONObject group = arr.getJSONObject(i);
                if ("test import".equals(group.getString("Name"))) groupId = group.getInt("idGroup");
            }
            
            exampleResult += "Given a default list id (use idList = 1), request for user visible groups<br/>GET "+url+" - OK<br/>";
            
            // If the list does not contain a group named âtest importâ, create it
            if (groupId == -1) {
                groupId = 100;
                url = mailUp.getConsoleEndpoint() + "/Console/List/1/Group";
                String groupRequest = "{\"Deletable\":true,\"Name\":\"test import\",\"Notes\":\"test import\"}";
                result = mailUp.callMethod(url, "POST", groupRequest, ContentType.Json, response);
                obj = new JSONObject(result);
                if ("test import".equals(obj.getString("Name"))) groupId = obj.getInt("idGroup");
                
                /*arr = obj.getJSONArray("Items");
                for (int i = 0; i < arr.length(); i++) {
                    JSONObject group = arr.getJSONObject(i);
                    if ("test import".equals(obj.getString("Name"))) groupId = obj.getInt("idGroup");
                }*/
            
                exampleResult += "If the list does not contain a group named \"test import\", create it<br/>POST "+url+" - OK<br/>";              
            }
            session.setAttribute("groupId", new Integer(groupId));
            
            // Request for dynamic fields to map recipient name and surname
            url = mailUp.getConsoleEndpoint() + "/Console/Recipient/DynamicFields";
            result = mailUp.callMethod(url, "GET", null, ContentType.Json, response);
            
            exampleResult += "Request for dynamic fields to map recipient name and surname<br/>GET "+url+" - OK<br/>";              
            
            // Import recipients to group
            url = mailUp.getConsoleEndpoint() + "/Console/Group/" + groupId + "/Recipients";
            String recipientRequest = "[{\"Email\":\"test@test.test\",\"Fields\":[{\"Description\":\"String description\",\"Id\":1,\"Value\":\"String value\"}],\"MobileNumber\":\"\",\"MobilePrefix\":\"\",\"Name\":\"John Smith\"}]";
            result = mailUp.callMethod(url, "POST", recipientRequest, ContentType.Json, response);
            int importId = Integer.parseInt(result);
           
            exampleResult += "Import recipients to group<br/>POST "+url+" - OK<br/>";              
            
            // Check the import result
            url = mailUp.getConsoleEndpoint() + "/Console/Import/" + importId;
            result = mailUp.callMethod(url, "GET", null, ContentType.Json, response);
            
            exampleResult += "Check the import result<br/>GET "+url+" - OK<br/>"; 
            
            exampleResult += "Example methods completed successfully<br/>";              
                   
        } catch (MailUpException ex) {
            exampleResult = "Error " + ex.getStatusCode() + ": " + ex.getMessage();
        } catch (Exception ex) {
            exampleResult = "Error " + ex.getMessage();
        }
    }
    
    // EXAMPLE 2 - UNSUBSCRIBE A RECIPIENT FROM A GROUP
    if (request.getParameter("RunExample2") != null) {
        try {
            
            // Request for recipient in a group
            String url = mailUp.getConsoleEndpoint() + "/Console/Group/" + groupId + "/Recipients";
            String result = mailUp.callMethod(url, "GET", null, ContentType.Json, response);
            JSONObject obj = new JSONObject(result);
            
            exampleResult += "Request for recipient in a group<br/>GET "+url+" - OK<br/>";
            
            JSONArray arr = obj.getJSONArray("Items");
            if (arr.length() > 0) {
                JSONObject recipient = arr.getJSONObject(0);
                int recipientId = recipient.getInt("idRecipient");
                
                // Pick up a recipient and unsubscribe it
                url = mailUp.getConsoleEndpoint() + "/Console/Group/" + groupId + "/Unsubscribe/" + recipientId;
                mailUp.callMethod(url, "DELETE", null, ContentType.Json, response);
            
                exampleResult += "Pick up a recipient and unsubscribe it<br/>DELETE "+url+" - OK<br/>";
            }
            
            exampleResult += "Example methods completed successfully<br/>";              
                   
        } catch (MailUpException ex) {
            exampleResult = "Error " + ex.getStatusCode() + ": " + ex.getMessage();
        } catch (Exception ex) {
            exampleResult = "Error " + ex.getMessage();
        }
    }
    
    // EXAMPLE 3 - UPDATE A RECIPIENT DETAIL
    if (request.getParameter("RunExample3") != null) {
        try {
            
            // Request for existing subscribed recipients
            String url = mailUp.getConsoleEndpoint() + "/Console/List/1/Recipients/Subscribed";
            String result = mailUp.callMethod(url, "GET", null, ContentType.Json, response);
            JSONObject obj = new JSONObject(result);
            
            exampleResult += "Request for existing subscribed recipients<br/>GET "+url+" - OK<br/>";
            
            JSONArray arr = obj.getJSONArray("Items");
            if (arr.length() > 0) {
                JSONObject recipient = arr.getJSONObject(0);
                JSONArray fields = recipient.getJSONArray("Fields");
                
                // Modify a recipient from the list
                if (fields.length() == 0)
                {
                    JSONObject o = new JSONObject();
                    o.put("Id", 1);
                    o.put("Value", "Updated value");
                    o.put("Description", "");
                    fields.put(o);
                }
                else
                {
                    JSONObject o = fields.getJSONObject(0);
                    o.put("Id", 1);
                    o.put("Value", "Updated value");
                    o.put("Description", "");
                }

                exampleResult += "Modify a recipient from the list - OK<br/>";
                
                // Update the modified recipient
                url = mailUp.getConsoleEndpoint() + "/Console/Recipient/Detail";
                mailUp.callMethod(url, "PUT", recipient.toString(), ContentType.Json, response);
            
                exampleResult += "Update the modified recipient<br/>PUT "+url+" - OK<br/>";
            } 
            
            exampleResult += "Example methods completed successfully<br/>";              
                   
        } catch (MailUpException ex) {
            exampleResult = "Error " + ex.getStatusCode() + ": " + ex.getMessage();
        } catch (Exception ex) {
            exampleResult = "Error " + ex.getMessage();
        }
    }
    
    // EXAMPLE 4 - CREATE A MESSAGE FROM TEMPLATE
    if (request.getParameter("RunExample4") != null) {
        try {
            
            // Get the available template list
            String url = mailUp.getConsoleEndpoint() + "/Console/List/1/Templates";
            String result = mailUp.callMethod(url, "GET", null, ContentType.Json, response);
            JSONObject obj = new JSONObject(result);
            JSONArray arr = obj.getJSONArray("Items");
            
            exampleResult += "Get the available template list<br/>GET "+url+" - OK<br/>";
            
            int templateId = -1;
            if (arr.length() > 0) templateId = arr.getJSONObject(0).getInt("Id"); 
            
            // Create the new message
            url = mailUp.getConsoleEndpoint() + "/Console/List/1/Email/Template/" + templateId;
            result = mailUp.callMethod(url, "POST", null, ContentType.Json, response);
            obj = new JSONObject(result);
            
            exampleResult += "Create the new message<br/>POST "+url+" - OK<br/>";
            /*
            arr = obj.getJSONArray("Items");
            if (arr.length() > 0) {
                JSONObject email = arr.getJSONObject(0);
                emailId = email.getInt("idMessage");
            }*/
            session.setAttribute("emailId", new Integer(obj.getInt("idMessage")));
            
            // Request for messages list
            url = mailUp.getConsoleEndpoint() + "/Console/List/1/Emails";
            result = mailUp.callMethod(url, "GET", null, ContentType.Json, response);
            
            exampleResult += "Request for messages list<br/>GET "+url+" - OK<br/>";
            
            exampleResult += "Example methods completed successfully<br/>";              
                   
        } catch (MailUpException ex) {
            exampleResult = "Error " + ex.getStatusCode() + ": " + ex.getMessage();
        } catch (Exception ex) {
            exampleResult = "Error " + ex.getMessage();
        }
    }
    
    // EXAMPLE 5 - CREATE A MESSAGE WITH IMAGES AND ATTACHMENTS
    if (request.getParameter("RunExample5") != null) {
        try {
            
            // Image bytes can be obtained from file, database or any other source
            URL img = new URL("https://www.google.it/images/srpr/logo11w.png"); 
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
            String url = mailUp.getConsoleEndpoint() + "/Console/List/1/Images";
            String imageRequest = "{\"Base64Data\":\""+base64+"\",\"Name\":\"Avatar.png\"}";
            String result = mailUp.callMethod(url, "POST", imageRequest, ContentType.Json, response); 
            
            exampleResult += "Upload an image<br/>POST "+url+" - OK<br/>";
            
            // Get the images available
            url = mailUp.getConsoleEndpoint() + "/Console/List/1/Images";
            result = mailUp.callMethod(url, "GET", null, ContentType.Json, response);
            
            String imgSrc = "";
            JSONArray arr = new JSONArray(result);
            if (arr.length() > 0) imgSrc = arr.getString(0);
            
            exampleResult += "Get the images available<br/>GET "+url+" - OK<br/>";
            
            // Create and save "hello" message
            String message = "<html><body><p>Hello</p><img src=\"http://"+imgSrc.replace("\\","/")+"\" /></body></html>";
            
            JSONObject email = new JSONObject();
            email.put("Subject", "Test Message JAVA");
            email.put("idList", 1);
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
            
            url = mailUp.getConsoleEndpoint() + "/Console/List/1/Email";
            result = mailUp.callMethod(url, "POST", email.toString(), ContentType.Json, response); 
            JSONObject obj = new JSONObject(result);
            
            exampleResult += "Create and save \"hello\" message<br/>POST "+url+" - OK<br/>";
            /*
            arr = obj.getJSONArray("Items");
            if (arr.length() > 0) {
                JSONObject msg = arr.getJSONObject(0);
                emailId = msg.getInt("idMessage");
            }*/
            session.setAttribute("emailId", new Integer(obj.getInt("idMessage")));
            emailId = obj.getInt("idMessage");
            
            // Add an attachment
            String attachment = "QmFzZSA2NCBTdHJlYW0="; // Base64 String
            String attachmentRequest = "{\"Base64Data\":\""+attachment+
                    "\",\"Name\":\"TestFile.txt\",\"Slot\":1,\"idList\":1,\"idMessage\":"+emailId+"}";
            url = mailUp.getConsoleEndpoint() + "/Console/List/1/Email/" + emailId + "/Attachment/1";
            result = mailUp.callMethod(url, "POST", attachmentRequest, ContentType.Json, response);
            
            exampleResult += "Add an attachment<br/>POST "+url+" - OK<br/>";
            
            // Retreive message details
            url = mailUp.getConsoleEndpoint() + "/Console/List/1/Email/" + emailId;
            result = mailUp.callMethod(url, "GET", null, ContentType.Json, response);
            
            exampleResult += "Retreive message details<br/>GET "+url+" - OK<br/>";
            
            exampleResult += "Example methods completed successfully<br/>";              
                   
        } catch (MailUpException ex) {
            exampleResult = "Error " + ex.getStatusCode() + ": " + ex.getMessage();
        } catch (Exception ex) {
            exampleResult = "Error " + ex.getMessage();
        }
    }
    
    // EXAMPLE 6 - TAG A MESSAGE
    if (request.getParameter("RunExample6") != null) {
        try {
            
            // Create a new tag
            String url = mailUp.getConsoleEndpoint() + "/Console/List/1/Tag";
            String result = mailUp.callMethod(url, "POST", "\"test tag\"", ContentType.Json, response);
            JSONObject obj = new JSONObject(result);
            
            exampleResult += "Create a new tag<br/>POST "+url+" - OK<br/>";
            
            int tagId = -1;
            //if (arr.length() > 0) tagId = arr.getJSONObject(0).getInt("Id");
            
            tagId = obj.getInt("Id");
            
            // Pick up a message and retrieve detailed informations
            url = mailUp.getConsoleEndpoint() + "/Console/List/1/Email/" + emailId;
            result = mailUp.callMethod(url, "GET", null, ContentType.Json, response);
            obj = new JSONObject(result);
            
            exampleResult += "Pick up a message and retrieve detailed informations<br/>GET "+url+" - OK<br/>";
            
            // Add the tag to the message details and save
            JSONArray tags = new JSONArray();
            JSONObject tag = new JSONObject();
            tag.put("Id", tagId);
            tag.put("Enabled", true);
            tag.put("Name", "test tag");
            tags.put(tag);
            obj.put("Tags", tags);
            
            url = mailUp.getConsoleEndpoint() + "/Console/List/1/Email/" + emailId;
            result = mailUp.callMethod(url, "PUT", obj.toString(), ContentType.Json, response);
            
            exampleResult += "Add the tag to the message details and save<br/>PUT "+url+" - OK<br/>";
            
            exampleResult += "Example methods completed successfully<br/>";              
                   
        } catch (MailUpException ex) {
            exampleResult = "Error " + ex.getStatusCode() + ": " + ex.getMessage();
        } catch (Exception ex) {
            exampleResult = "Error " + ex.getMessage();
        }
    }
    
    // EXAMPLE 7 - SEND A MESSAGE
    if (request.getParameter("RunExample7") != null) {
        try {
            
            // Get the list of the existing messages
            String url = mailUp.getConsoleEndpoint() + "/Console/List/1/Emails";
            String result = mailUp.callMethod(url, "GET", null, ContentType.Json, response);
            JSONObject obj = new JSONObject(result);
            
            exampleResult += "Get the list of the existing messages<br/>GET "+url+" - OK<br/>";
            
            JSONArray arr = obj.getJSONArray("Items");
            if (arr.length() > 0) {
                JSONObject email = arr.getJSONObject(0);
                emailId = email.getInt("idMessage");
            }
            session.setAttribute("emailId", new Integer(emailId)); 
            
            // Send email to all recipients in the list
            url = mailUp.getConsoleEndpoint() + "/Console/List/1/Email/" + emailId + "/Send";
            result = mailUp.callMethod(url, "POST", null, ContentType.Json, response);
            
            exampleResult += "Send email to all recipients in the list<br/>POST "+url+" - OK<br/>";
            
            exampleResult += "Example methods completed successfully<br/>";              
                   
        } catch (MailUpException ex) {
            exampleResult = "Error " + ex.getStatusCode() + ": " + ex.getMessage();
        } catch (Exception ex) {
            exampleResult = "Error " + ex.getMessage();
        }
    }
    
    // EXAMPLE 8 - DISPLAY STATISTICS FOR A MESSAGE SENT AT EXAMPLE 7
    if (request.getParameter("RunExample8") != null) {
        try {
            
            // Request (to MailStatisticsService.svc) for paged message views list for the previously sent message
            int hours = 4;
            String url = mailUp.getMailstatisticsEndpoint() + "/Message/" + emailId + "/List/Views?pageSize=5&pageNum=0";
            String result = mailUp.callMethod(url, "GET", null, ContentType.Json, response);
            
            exampleResult += "Request (to MailStatisticsService.svc) for paged message views list for the previously sent message<br/>GET "+url+" - OK<br/>";
            
            exampleResult += "Example methods completed successfully<br/>";              
                   
        } catch (MailUpException ex) {
            exampleResult = "Error " + ex.getStatusCode() + ": " + ex.getMessage();
        } catch (Exception ex) {
            exampleResult = "Error " + ex.getMessage();
        }
    }
    
    
    // Writing page output
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>MailUp Demo Client</title>
    </head>
    <body>
    <h2>
        MailUp Demo Client
    </h2>
    
    <form action="index.jsp" method="POST">
    <p>
        <input type="submit" name="LogOn" value="Sign in to MailUp"/>
    </p>
    <p>
        Username: <input type="text" name="txtUsr" value="type your MailUp username" style="width:400px;"/><br/>
        Password: <input type="text" name="txtPwd" value="type your MailUp password" style="width:400px;"/><br/>
        <input type="submit" name="LogOnWithUsernamePassword" value="Sign in to MailUp with username and password."/>
    </p>
    
    
    <p id="pAuthorization"><%= mailUp.getAccessToken()==null?"Unauthorized":("Authorized. Token: "+mailUp.getAccessToken())%></p><br /><br />

    <p><b>Custom method call</b></p>
    <table>
    <thead>
    <td>Verb</td>
    <td>Content-Type</td>
    <td>Endpoint</td>
    <td>Path</td>
    </thead>
    <tr>
        <td><select name="lstVerb">
                <option value="GET">GET</option>
                <option value="POST">POST</option>
            </select></td>
    <td><select name="lstContentType">
                <option value="JSON">JSON</option>
                <option value="XML">XML</option>
        </select></td>
    <td><select name="lstEndpoint">
            <option value="<%= mailUp.getConsoleEndpoint() %>">Console</option>
            <option value="<%= mailUp.getMailstatisticsEndpoint() %>">MailStatistics</option>
        </select></td>
    <td><input type="text" name="txtPath" value="/Console/Authentication/Info" style="width:200px;"/></td>
    </tr>
    </table>

    <p>Body</p><p><textarea name="txtBody" rows="5" cols="60"></textarea></p>
    <p>
        <input type="submit" name="CallMethod" value="Call Method"/>
    </p>

    <p id="pResultString"><%= callResult %></p><br /><br />

    <p><b>Run example set of calls</b></p>
    
    <p id="pExampleResultString"><%= exampleResult %></p>
    <p>
        <input type="submit" name="RunExample1" value="Run example code 1 - Import recipients"/>
    </p>
    <p>
        <input type="submit" name="RunExample2" value="Run example code 2 - Unsubscripe a recipient"/>
    </p>
    <p>
        <input type="submit" name="RunExample3" value="Run example code 3 - Update a recipient"/>
    </p>
    <p>
        <input type="submit" name="RunExample4" value="Run example code 4 - Create a message from template"/>
    </p>
    <p>
        <input type="submit" name="RunExample5" value="Run example code 5 - Create a message from scratch"/>
    </p>
    <p>
        <input type="submit" name="RunExample6" value="Run example code 6 - Tag a message"/>
    </p>
    <p>
        <input type="submit" name="RunExample7" value="Run example code 7 - Send a message"/>
    </p>
    <p>
        <input type="submit" name="RunExample8" value="Run example code 8 - Retreive statistics"/>
    </p>
    </form>
    </body>
</html>
