<%@page contentType="text/html" import="com.mailup.*,org.json.*,java.net.*,java.io.*,org.apache.commons.codec.binary.*" pageEncoding="UTF-8"%>
<%@page import="java.util.ResourceBundle" %>

<%!
    private static String TEMPLATE_HEADER = "<div class=\"spoiler-wrap disabled\">\n"
            + "    <div class=\"spoiler-head\">%s</div>\n"
            + "    <div class=\"spoiler-body\">";

    private static String TEMPLATE_REQUEST = "<div class=\"well\">\n"
            + "            <div class=\"form-group row\">\n"
            + "                <div class=\"col-xs-2\"><label>Verb</label><span class=\"form-control\">%s</span></div>\n"
            + "                <div class=\"col-xs-2\"><label>Content-Type</label><span class=\"form-control\">%s</span></div>\n"
            + "                <div class=\"col-xs-2\"><label>Endpoint</label><span class=\"form-control\">%s</span></div>\n"
            + "                <div class=\"col-xs-6\"><label>Path</label><span class=\"form-control\">%s</span></div>\n"
            + "            </div>\n"
            + "            <div class=\"form-group\"><label>Body</label>\n"
            + "                <div class=\"form-control example-body\">%s</div>\n"
            + "            </div>\n"
            + "        </div>\n";

    private static String TEMPLATE_RESPONSE = "<div class=\"well\">\n"
            + "            <div class=\"form-group example-body\"><label>Response</label>\n"
            + "                <div>%s</div>\n"
            + "            </div>\n"
            + "        </div>\n"
            + "    </div>\n"
            + "</div>";

    private static String TEMPLATE_COMPLETED = "<div class=\"example-result text-success\">Example methods completed successfully</div>";
    private static String TEMPLATE_ERROR = "</div></div><div class=\"example-result text-danger\">Error %s</div>";
    private static String TEMPLATE_WARNING = "<div class=\"example-result text-warning\">Warning %s</div>";
%>

<%
    ResourceBundle resource = ResourceBundle.getBundle("com.mailup.mailup");

    // Initializing MailUpClient
    MailUpClient mailUp = new MailUpClient(
            resource.getString("mailup.client.id"),
            resource.getString("mailup.client.secret"),
            resource.getString("mailup.callback.uri"), request);

    request.setAttribute("mailUp", mailUp);
    request.setAttribute("idList", resource.getString("mailup.id.list"));
    request.setAttribute("templateHeader", TEMPLATE_HEADER);
    request.setAttribute("templateRequest", TEMPLATE_REQUEST);
    request.setAttribute("templateResponse", TEMPLATE_RESPONSE);
    request.setAttribute("templateCompleted", TEMPLATE_COMPLETED);
    request.setAttribute("templateError", TEMPLATE_ERROR);
    request.setAttribute("templateWarning", TEMPLATE_WARNING);

    // Logging In
    if (request.getParameter("LogOn") != null) { // LogOn button clicked
        mailUp.logOn(response);
    } else if (request.getParameter("code") != null) { // code returned by MailUp
        mailUp.retreiveAccessToken(request.getParameter("code"), response);
    }

    // LogOn with Username/Password
    String loginError = "";
    if (request.getParameter("LogOnWithUsernamePassword") != null) {
        try {
            mailUp.logOnWithUsernamePassword(request.getParameter("txtUsr"), request.getParameter("txtPwd"), response);
        } catch (MailUpException ex) {
            loginError = "Exception with code " + ex.getStatusCode() + " and message: " + ex.getMessage();
        }
    }

    //Refresh token
    if (request.getParameter("RefreshMethod") != null) {
        try {
            mailUp.refreshAccessToken(response);
        } catch (MailUpException ex) {
            loginError = "Exception with code " + ex.getStatusCode() + " and message: " + ex.getMessage();
        }
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>MailUp Demo Client</title>

        <!--bootstrap-->
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
        <link rel="stylesheet" href="resources/css/styles.css">

        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
        <script src="resources/js/javascript.js"></script>

    </head>

    <body>
        <div id="load"></div>
        <div id="contents" class="container">
            <div class="bd-pageheader text-center text-sm-left">   
                <h1><strong>MailUp Demo Client</strong></h1>
            </div>

            <h3><strong>Authentication</strong></h3>

            <div class="row">
                <div class="col-sm-3">
                    <div class="panel panel-default auth-panel">
                        <div class="panel-heading">Authorization code grant</div>
                        <div class="panel-body">
                            <form action="index.jsp" method="POST" class="auth-panel-sign">
                                <button type="submit" class="btn btn-default" name="LogOn">Sign in to MailUp</button>
                            </form>
                        </div>
                    </div>
                </div>

                <div class="col-sm-9">
                    <div class="panel panel-default auth-panel">
                        <div class="panel-heading">Password grant</div>
                        <div class="panel-body">
                            <form action="index.jsp" method="POST">
                                <div class="form-group">
                                    <label for="txtUsr">Username:</label>
                                    <input id="txtUsr" name="txtUsr" type="text" class="form-control" placeholder="type your MailUp username">
                                </div>
                                <div class="form-group">
                                    <label for="txtPwd">Password:</label>
                                    <input id="txtPwd" name="txtPwd" type="text" class="form-control" placeholder="type your MailUp password">
                                </div>

                                <button id="logOnWithUsernamePassword" name="LogOnWithUsernamePassword"type="submit" class="btn btn-success" disabled='disabled'>Sign in to MailUp with username and password</button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-sm-10">
                    <div id="pAuthorization" class = "example-body" style="margin-top: 15px;">
                        <div><%= mailUp.getAccessToken() == null ? "<strong>Unauthorized</strong>" : "<strong>Authorized.</strong> "%></div>
                        <div class="<%= (mailUp.getAccessToken() == null) ? "display-none" : ""%>">
                            <input id="expiresInTimerValue" type="hidden" value="<%=mailUp.getExpiresIn()%>"/>
                            <div><strong>Token: </strong><span><%=mailUp.getAccessToken()%></span></div>
                            <div><strong>Expires in </strong><span id="expiresInTimer"></span></div>
                        </div>
                    </div>

                    <div class="text-danger"><%=loginError%></div>
                </div>

                <div class="col-sm-2 right">
                    <form action="index.jsp" method="POST">
                        <button type="submit" name="RefreshMethod" class="btn btn-success" 
                                <%= (mailUp.getRefreshToken() == null) ? "disabled='disabled'" : ""%>
                        >Refresh token</button>
                    </form>
                </div>
            </div>

            <jsp:include page="pages/customCall.jsp" />

            <h3><strong>Run example set of calls</strong></h3> 
            <jsp:include page="pages/examples/runExample1.jsp" />
            <jsp:include page="pages/examples/runExample2.jsp" />
            <jsp:include page="pages/examples/runExample3.jsp" />
            <jsp:include page="pages/examples/runExample4.jsp" />
            <jsp:include page="pages/examples/runExample5.jsp" />
            <jsp:include page="pages/examples/runExample6.jsp" />
            <jsp:include page="pages/examples/runExample7.jsp" />
            <jsp:include page="pages/examples/runExample8.jsp" />

        </div>
    </body>
</html>
